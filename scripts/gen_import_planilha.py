# -*- coding: utf-8 -*-
"""
Gerador do script SQL de importacao da planilha "Form 139" (manutencao preventiva).

Le a aba do ano informado da planilha .xls e gera um script SQL idempotente
que popula ti.ativos + ti.ciclos_manutencao (com itens de checklist) com DATAS
FIXAS, marcando cada ciclo como Concluido (R = Realizado) ou Pendente (P = Previsto).

Uso:
    python scripts/gen_import_planilha.py "<caminho .xls>" 2026 > scripts/011_import_planilha_2026.sql

Mapa de criticidade da planilha -> sistema:
    1 (30 dias) -> Alta
    2 (60 dias) -> Media   (gravado como 'Média' no banco)
    3 (180 dias) -> Baixa
"""
import sys
import unicodedata
import datetime as dt
import pandas as pd

CRIT_MAP = {"1": "Alta", "2": "Média", "3": "Baixa"}
VALID_CRIT = set(CRIT_MAP.keys())


def clean_name(value: str) -> str:
    """Normaliza o nome da maquina para ASCII (os nomes da planilha ja sao
    ASCII maiusculo; um deles veio corrompido do .xls). Remove acentos e
    caracteres invalidos para manter o cadastro consistente."""
    text = str(value).replace("�", "")  # remove replacement char do .xls
    text = unicodedata.normalize("NFKD", text)
    text = text.encode("ascii", "ignore").decode("ascii")
    return text.strip()


def sql_str(value: str) -> str:
    """Escapa uma string para literal SQL (aspas simples)."""
    return "'" + str(value).replace("'", "''") + "'"


def parse_args():
    if len(sys.argv) < 3:
        sys.stderr.write("uso: gen_import_planilha.py <arquivo.xls> <ano> [saida.sql]\n")
        sys.exit(1)
    saida = sys.argv[3] if len(sys.argv) > 3 else None
    return sys.argv[1], int(sys.argv[2]), saida


def main():
    path, year, saida = parse_args()
    # Garante saida em UTF-8 (nomes/comentarios acentuados) independente do shell.
    if saida:
        sys.stdout = open(saida, "w", encoding="utf-8", newline="\n")
    else:
        sys.stdout.reconfigure(encoding="utf-8", newline="\n")
    sheet = f"Form 139 15-10-10 rev.02 {year}"
    df = pd.read_excel(path, sheet_name=sheet, header=1)

    nome_col = df.columns[0]
    crit_col = df.columns[1]
    # As 12 colunas de data ficam logo apos a coluna de criticidade,
    # intercaladas com colunas P/R. Posicoes pares = data, impares = flag.
    month_cols = list(df.columns[2:26])  # JAN, P/R, FEV, P/R, ... DEZ, P/R

    df = df.dropna(subset=[nome_col])

    seen = set()
    assets = []  # (nome, criticidade_sistema, [(data_iso, feito_bool), ...])

    for _, row in df.iterrows():
        crit_raw = str(row[crit_col]).strip()
        if crit_raw not in VALID_CRIT:
            continue  # pula linhas de legenda / totais
        nome = clean_name(row[nome_col])
        if not nome or nome.lower() in seen:
            continue
        seen.add(nome.lower())

        ciclos = []
        for i in range(0, len(month_cols), 2):
            data_val = row[month_cols[i]]
            flag = str(row[month_cols[i + 1]]).strip().upper() if i + 1 < len(month_cols) else ""
            if pd.isna(data_val):
                continue
            if isinstance(data_val, (dt.datetime, dt.date, pd.Timestamp)):
                data_iso = pd.Timestamp(data_val).strftime("%Y-%m-%d")
            else:
                continue
            feito = flag == "R"
            ciclos.append((data_iso, feito))

        assets.append((nome, CRIT_MAP[crit_raw], ciclos))

    emit(assets, year)


def emit(assets, year):
    out = sys.stdout.write
    total_ciclos = sum(len(c) for _, _, c in assets)
    out(f"-- ============================================================================\n")
    out(f"-- 011_import_planilha_{year}.sql\n")
    out(f"-- Importacao da planilha 'Form 139' (manutencao preventiva) - ano {year}.\n")
    out(f"-- Gerado por scripts/gen_import_planilha.py. NAO editar a mao.\n")
    out(f"-- Ativos: {len(assets)} | Ciclos: {total_ciclos}\n")
    out(f"-- Idempotente: pode ser reexecutado sem duplicar (casa ativo por nome).\n")
    out(f"-- ============================================================================\n\n")
    out("BEGIN;\n")
    out("SET search_path TO ti;\n\n")

    out("-- Coluna de justificativa do registro de execucao (data feita + justificativa).\n")
    out("ALTER TABLE ti.registros_manutencao ADD COLUMN IF NOT EXISTS justificativa TEXT;\n\n")

    out("-- Garante que nao haja ciclos duplicados (mesmo ativo + mesma data planejada).\n")
    out("CREATE UNIQUE INDEX IF NOT EXISTS uq_ciclos_ativo_data\n")
    out("    ON ti.ciclos_manutencao(ativo_id, data_proxima_manutencao);\n\n")

    out("DO $$\n")
    out("DECLARE\n")
    out("    v_ativo_id UUID;\n")
    out("    v_ciclo_id UUID;\n")
    out("    v_item TEXT;\n")
    out("    v_checklist TEXT[] := ARRAY[\n")
    out("        'Limpeza fisica do equipamento',\n")
    out("        'Troca de teclado e mouse (se necessario)',\n")
    out("        'Verificacao de cabos e conexoes',\n")
    out("        'Desfragmentacao (se necessario)',\n")
    out("        'Atualizacao de antivirus e Windows Update',\n")
    out("        'Atualizar campo \"Ultima Preventiva\"'\n")
    out("    ];\n")
    out("BEGIN\n")

    for nome, crit, ciclos in assets:
        # ultima manutencao = maior data com R; proxima = menor data com P
        feitas = sorted(d for d, f in ciclos if f)
        previstas = sorted(d for d, f in ciclos if not f)
        ultima = feitas[-1] if feitas else "NULL"
        proxima = previstas[0] if previstas else (feitas[-1] if feitas else "NULL")
        ultima_sql = sql_str(ultima) if ultima != "NULL" else "NULL"
        proxima_sql = sql_str(proxima) if proxima != "NULL" else "NULL"

        out(f"\n    -- ----- {nome} (criticidade {crit}) -----\n")
        out("    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower(")
        out(f"{sql_str(nome)}) LIMIT 1;\n")
        out("    IF v_ativo_id IS NULL THEN\n")
        out("        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)\n")
        out(f"        VALUES ({sql_str(nome)}, 'Equipamento', 'Nao informado', {sql_str(crit)}, 'Operacional', {ultima_sql}, {proxima_sql})\n")
        out("        RETURNING id INTO v_ativo_id;\n")
        out("    ELSE\n")
        out("        UPDATE ti.ativos\n")
        out(f"           SET criticidade = {sql_str(crit)},\n")
        out(f"               ultima_manutencao = COALESCE({ultima_sql}, ultima_manutencao),\n")
        out(f"               proxima_manutencao = {proxima_sql}\n")
        out("         WHERE id = v_ativo_id;\n")
        out("    END IF;\n")

        for data_iso, feito in ciclos:
            status = "Concluído" if feito else "Pendente"
            data_fim = sql_str(data_iso) if feito else "NULL"
            out(f"    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)\n")
            out(f"    VALUES (v_ativo_id, {sql_str(data_iso)}, {data_fim}, {sql_str(status)})\n")
            out("    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE\n")
            out("        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim\n")
            out("    RETURNING id INTO v_ciclo_id;\n")
            out("    FOREACH v_item IN ARRAY v_checklist LOOP\n")
            out("        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)\n")
            out(f"        SELECT v_ciclo_id, v_item, {'TRUE' if feito else 'FALSE'}\n")
            out("        WHERE NOT EXISTS (\n")
            out("            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item\n")
            out("        );\n")
            out("    END LOOP;\n")
            if feito:
                out("    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)\n")
                out(f"    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', {sql_str(data_iso)}::timestamptz, 'Concluída'\n")
                out("    WHERE NOT EXISTS (\n")
                out("        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id\n")
                out("    );\n")

    out("END $$;\n\n")
    out("COMMIT;\n")


if __name__ == "__main__":
    main()

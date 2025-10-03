from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfbase import pdfmetrics

# Registrar Arial (se não tiver, pode usar DejaVuSans como substituto)
#pdfmetrics.registerFont(TTFont("Arial", "DejaVuSans.ttf"))
pdfmetrics.registerFont(TTFont("Arial", "C:/Windows/Fonts/arial.ttf"))


# Criar documento
doc = SimpleDocTemplate("documento_juridico_teste.pdf", pagesize=A4)
styles = getSampleStyleSheet()

# Estilo com fonte Arial
estilo_arial = ParagraphStyle(
    'JuridicoArial',
    parent=styles['Normal'],
    fontName="Arial",
    fontSize=12,
    leading=16,
    spaceAfter=12,
)

conteudo = []


# Substituições já aplicadas (Fulano -> João, Beltrano -> Maria)
texto1 = """
EXCELENTÍSSIMO SENHOR DOUTOR JUIZ DE DIREITO DA ___ VARA CÍVEL DA COMARCA DE SÃO PAULO - SP
"""
texto2 = """
JOÃO, brasileiro, solteiro, advogado, inscrito na OAB/SP sob o nº 000000, com escritório profissional situado na Rua das Flores, nº 123, Bairro Centro, São Paulo/SP, por meio de seu advogado infra-assinado, vem, respeitosamente, à presença de Vossa Excelência propor a presente
AÇÃO DE OBRIGAÇÃO DE FAZER
em face de MARIA, brasileira, empresária, inscrita no CPF sob o nº 111.111.111-11, residente e domiciliada na Rua das Palmeiras, nº 456, Bairro Jardim, São Paulo/SP, pelos motivos de fato e de direito a seguir expostos.
"""
texto3 = """
DOS FATOS
O Requerente celebrou contrato de prestação de serviços com a Requerida em 10 de janeiro de 2022, com prazo de vigência de 12 meses. Ocorre que a Requerida deixou de cumprir com as obrigações assumidas, notadamente no que se refere ao pagamento das parcelas mensais ajustadas, o que vem causando graves prejuízos ao Requerente.
"""
texto4 = """
DO DIREITO
Nos termos do artigo 389 do Código Civil, o inadimplemento das obrigações contratuais sujeita o devedor ao pagamento de perdas e danos, além de juros e correção monetária. Assim, resta evidente a obrigação da Requerida em reparar os prejuízos sofridos pelo Requerente.
"""
texto5 = """
DOS PEDIDOS
Diante do exposto, requer-se:
1. A citação da Requerida para, querendo, apresentar defesa, sob pena de revelia;
2. A condenação da Requerida ao pagamento das parcelas vencidas e vincendas, acrescidas de juros e correção monetária;
3. A condenação da Requerida ao pagamento de honorários advocatícios, nos termos do artigo 85 do CPC;
4. A produção de todas as provas em direito admitidas, especialmente a documental e testemunhal;
5. A procedência total da presente demanda.
Nestes termos, pede deferimento.
São Paulo, 03 de outubro de 2025.
"""
texto6 = """
_____________________________________
JOÃO
OAB/SP 000000
"""
# Textos já adaptados com João e Maria
for t in [texto1, texto2, texto3, texto4, texto5, texto6]:
    conteudo.append(Paragraph(t.strip(), estilo_arial))
    conteudo.append(Spacer(1, 12))

# Construir PDF
doc.build(conteudo)

"/documento_juridico_teste_arial.pdf"

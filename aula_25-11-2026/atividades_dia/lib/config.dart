// endereço do servidor (XAMPP)
const servidor = '10.106.76.19';

const nomesMeses = [
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];

String _doisDigitos(int numero) => numero.toString().padLeft(2, '0');

// formato que o PHP/MySQL espera: aaaa-mm-dd
String dataParaApi(DateTime data) =>
    '${data.year}-${_doisDigitos(data.month)}-${_doisDigitos(data.day)}';

// formato mostrado na tela: dd/mm/aaaa
String dataParaTela(DateTime data) =>
    '${_doisDigitos(data.day)}/${_doisDigitos(data.month)}/${data.year}';

// data de hoje sem as horas (a última que pode ser escolhida)
DateTime hoje() {
  final agora = DateTime.now();
  return DateTime(agora.year, agora.month, agora.day);
}

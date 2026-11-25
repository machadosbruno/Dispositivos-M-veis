<?php
date_default_timezone_set('America/Sao_Paulo');

$dia = $_POST['dia'] ?? '';             // aaaa-mm-dd
$titulo = trim($_POST['titulo'] ?? '');
$descricao = trim($_POST['descricao'] ?? '');

// o título é obrigatório
if ($titulo === '') {
    echo "Erro -> informe o titulo";
    exit;
}

// a data precisa existir e não pode ser futura
$data = DateTime::createFromFormat('!Y-m-d', $dia);
if (!$data || $data->format('Y-m-d') !== $dia) {
    echo "Erro -> data invalida";
    exit;
}
if ($dia > date('Y-m-d')) {
    echo "Erro -> a data nao pode ser futura";
    exit;
}

$dsn = 'mysql:dbname=atividades_dia;host=127.0.0.1;charset=utf8mb4';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$sth = $dbh->prepare(
    "INSERT INTO `atividades` (`id`, `dia`, `titulo`, `descricao`) VALUES (NULL, :dia, :titulo, :descricao)"
);
$resultado = $sth->execute([
    'dia' => $dia,
    'titulo' => mb_substr($titulo, 0, 100),
    'descricao' => $descricao === '' ? null : mb_substr($descricao, 0, 200),
]);

if($resultado) {
    echo "Atividade salva! id=" . $dbh->lastInsertId();
} else {
    echo "Erro -> nao foi possivel salvar";
}
?>

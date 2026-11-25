<?php
header('Content-Type: application/json; charset=utf-8');

$mes = $_GET['mes'];
$ano = $_GET['ano'];

$dsn = 'mysql:dbname=atividades_dia;host=127.0.0.1;charset=utf8mb4';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

// todas as atividades do mês, em ordem de dia (e de cadastro dentro do dia)
$sth = $dbh->prepare("
    SELECT id, dia, titulo, descricao
    FROM `atividades`
    WHERE MONTH(dia) = :mes AND YEAR(dia) = :ano
    ORDER BY dia, id
");
$sth->execute(['mes' => $mes, 'ano' => $ano]);

$resultado = $sth->fetchAll(PDO::FETCH_ASSOC);

echo json_encode($resultado);
?>

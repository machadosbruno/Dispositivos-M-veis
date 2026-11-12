<?php
header('Content-Type: application/json; charset=utf-8');

$usuarioId = $_GET['usuario_id'];

$dsn = 'mysql:dbname=bancoBruno;host=127.0.0.1;charset=utf8mb4';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$sth = $dbh->prepare("
    SELECT a.id, a.solicitante_id, u.nome AS solicitante_nome
    FROM `solicitacoes_amizade` a
    LEFT JOIN `usuarios` u ON u.id = a.solicitante_id
    WHERE a.solicitado_id = :usuario_id AND a.status = 'PENDENTE'
    ORDER BY a.id DESC
");
$sth->execute(['usuario_id' => $usuarioId]);

echo json_encode($sth->fetchAll(PDO::FETCH_ASSOC));
?>

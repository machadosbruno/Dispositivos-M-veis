<?php
header('Content-Type: application/json; charset=utf-8');

$usuarioAtual = $_GET['usuario_id'];

$dsn = 'mysql:dbname=bancoBruno;host=127.0.0.1;charset=utf8mb4';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$sth = $dbh->prepare("
    SELECT
        u.id,
        u.nome,
        COALESCE(
            (SELECT a.status FROM solicitacoes_amizade a
             WHERE a.solicitante_id = :usuario_atual AND a.solicitado_id = u.id),
            (SELECT a.status FROM solicitacoes_amizade a
             WHERE a.solicitado_id = :usuario_atual AND a.solicitante_id = u.id),
            'NENHUM'
        ) AS status_amizade,
        EXISTS(
            SELECT 1 FROM solicitacoes_amizade a
            WHERE a.solicitante_id = :usuario_atual AND a.solicitado_id = u.id
        ) AS pedido_meu
    FROM `usuarios` u
    WHERE u.id != :usuario_atual
    ORDER BY u.nome ASC
");
$sth->execute(['usuario_atual' => $usuarioAtual]);

echo json_encode($sth->fetchAll(PDO::FETCH_ASSOC));
?>

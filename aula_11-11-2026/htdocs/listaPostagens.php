<?php
header('Content-Type: application/json; charset=utf-8');

$usuarioAtual = $_GET['usuario_id'];

$dsn = 'mysql:dbname=bancoBruno;host=127.0.0.1;charset=utf8mb4';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$sth = $dbh->prepare("
    SELECT
        p.id,
        p.usuario_id,
        u.nome AS autor,
        p.texto,
        p.caminho,
        (SELECT COUNT(*) FROM curtidas c WHERE c.postagem_id = p.id) AS curtidas,
        EXISTS(
            SELECT 1 FROM curtidas c
            WHERE c.postagem_id = p.id AND c.usuario_id = :usuario_atual
        ) AS curtida_do_usuario,
        (
            p.usuario_id = :usuario_atual OR EXISTS(
                SELECT 1 FROM solicitacoes_amizade a
                WHERE a.status = 'ACEITO'
                  AND (
                      (a.solicitante_id = :usuario_atual AND a.solicitado_id = p.usuario_id)
                      OR (a.solicitado_id = :usuario_atual AND a.solicitante_id = p.usuario_id)
                  )
            )
        ) AS pode_comentar
    FROM `postagens` p
    LEFT JOIN `usuarios` u ON u.id = p.usuario_id
    ORDER BY p.id DESC
");
$sth->execute(['usuario_atual' => $usuarioAtual]);

$resultado = $sth->fetchAll(PDO::FETCH_ASSOC);

echo json_encode($resultado);
?>

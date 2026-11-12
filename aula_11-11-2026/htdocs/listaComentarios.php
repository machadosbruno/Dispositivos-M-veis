<?php
header('Content-Type: application/json; charset=utf-8');

$postagemId = $_GET['postagem_id'];
$usuarioAtual = $_GET['usuario_id'];

$dsn = 'mysql:dbname=bancoBruno;host=127.0.0.1;charset=utf8mb4';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$sth = $dbh->prepare("
    SELECT
        p.usuario_id,
        (
            p.usuario_id = :usuario_atual OR EXISTS(
                SELECT 1 FROM solicitacoes_amizade a
                WHERE a.status = 'ACEITO'
                  AND (
                      (a.solicitante_id = :usuario_atual AND a.solicitado_id = p.usuario_id)
                      OR (a.solicitado_id = :usuario_atual AND a.solicitante_id = p.usuario_id)
                  )
            )
        ) AS pode_ver
    FROM `postagens` p
    WHERE p.id = :postagem_id
");
$sth->execute(['postagem_id' => $postagemId, 'usuario_atual' => $usuarioAtual]);
$postagem = $sth->fetch(PDO::FETCH_ASSOC);

if (!$postagem || !$postagem['pode_ver']) {
    echo json_encode(['erro' => 'Somente amigos do autor podem ver os comentarios.']);
    exit;
}

$sth = $dbh->prepare("
    SELECT c.id, c.usuario_id, u.nome AS autor, c.texto
    FROM `comentarios` c
    LEFT JOIN `usuarios` u ON u.id = c.usuario_id
    WHERE c.postagem_id = :postagem_id
    ORDER BY c.id ASC
");
$sth->execute(['postagem_id' => $postagemId]);

echo json_encode($sth->fetchAll(PDO::FETCH_ASSOC));
?>

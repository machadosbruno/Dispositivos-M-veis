<?php
header('Content-Type: application/json; charset=utf-8');

$postagemId = $_GET['postagem_id'];
$usuarioId = $_GET['usuario_id'];

$dsn = 'mysql:dbname=bancoBruno;host=127.0.0.1;charset=utf8mb4';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$sth = $dbh->prepare(
    "SELECT id FROM `curtidas` WHERE postagem_id = :postagem_id AND usuario_id = :usuario_id"
);
$sth->execute(['postagem_id' => $postagemId, 'usuario_id' => $usuarioId]);
$curtida = $sth->fetch(PDO::FETCH_ASSOC);

if ($curtida) {
    $sth = $dbh->prepare("DELETE FROM `curtidas` WHERE id = :id");
    $sth->execute(['id' => $curtida['id']]);
    $curtiu = false;
} else {
    $sth = $dbh->prepare(
        "INSERT INTO `curtidas` (`id`, `postagem_id`, `usuario_id`) VALUES (NULL, :postagem_id, :usuario_id)"
    );
    $sth->execute(['postagem_id' => $postagemId, 'usuario_id' => $usuarioId]);
    $curtiu = true;
}

$sth = $dbh->prepare("SELECT COUNT(*) AS total FROM `curtidas` WHERE postagem_id = :postagem_id");
$sth->execute(['postagem_id' => $postagemId]);
$total = $sth->fetch(PDO::FETCH_ASSOC)['total'];

echo json_encode(['curtida_do_usuario' => $curtiu, 'curtidas' => (int) $total]);
?>

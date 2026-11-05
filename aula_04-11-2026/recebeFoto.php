<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Recebe a foto</title>
</head>
<body>
    <form action="salvaFoto.php" method="post" enctype="multipart/form-data">
        <label for="">Foto:</label>
        <input type="file" name="foto"><br>
        <input type="submit">
    </form>
</body>
</html>

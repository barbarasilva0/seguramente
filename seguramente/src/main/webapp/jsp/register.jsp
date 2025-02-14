<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<%
    String username = request.getParameter("username");
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    boolean registrationSuccess = false;
    String errorMessage = "";

    if (username != null && email != null && password != null) {
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/segura_utilizadores", "root", "!5xne5Qui8900");
            
            String checkQuery = "SELECT Email FROM Utilizador WHERE Email = ?";
            stmt = conn.prepareStatement(checkQuery);
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                errorMessage = "Este email já está registado.";
            } else {
                String insertQuery = "INSERT INTO Utilizador (Nome, Email, Password, Tipo_de_Utilizador) VALUES (?, ?, ?, 'Jogador')";
                stmt = conn.prepareStatement(insertQuery);
                stmt.setString(1, username);
                stmt.setString(2, email);
                stmt.setString(3, password);
                stmt.executeUpdate();
                registrationSuccess = true;
            }
            rs.close();
        } catch (Exception e) {
            e.printStackTrace();
            errorMessage = "Erro ao registar. Tente novamente.";
        } finally {
            try { if (stmt != null) stmt.close(); if (conn != null) conn.close(); } catch (Exception e) { e.printStackTrace(); }
        }
    }
%>

<!DOCTYPE html>
<html lang="pt-PT">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registo - SeguraMente</title>
    <link rel="stylesheet" href="html/css/register.css">
</head>
<body>
    <div class="container">
        <div class="left"></div>
        <div class="right">
            <div class="site-title">
                <a href="../index.html" class="site-title-link">SeguraMente</a>
            </div>            
            <h1>Cria a tua conta</h1>
            <% if (registrationSuccess) { %>
                <p style="color: green;">Registo concluído com sucesso! </p>
                <script>
                    setTimeout(function() {
                        window.location.href = 'dashboard.jsp';
                    }, 1500);
                </script>
            <% } else if (!errorMessage.isEmpty()) { %>
                <p style="color: red;"><%= errorMessage %></p>
            <% } %>
            <form method="post" action="register.jsp">
                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username" placeholder="Cria o teu username" required>
                </div>
                <div class="form-group">
                    <label for="email">Email*</label>
                    <input type="email" id="email" name="email" placeholder="Insere o teu email" required>
                </div>
                <div class="form-group">
                    <label for="password">Palavra-passe*</label>
                    <input type="password" id="password" name="password" placeholder="Palavra-passe" required>
                </div>
                <button type="submit" class="btn-primary">Registar</button>
            </form>
        </div>
    </div>
</body>
</html>
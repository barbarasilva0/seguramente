<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Verifica se o usuário está logado e recupera os dados da sessão
    Integer idUsuario = null;
    if(session.getAttribute("idUsuario") != null) {
        try {
            idUsuario = Integer.parseInt(session.getAttribute("idUsuario").toString());
        } catch(Exception ex) {
            idUsuario = null;
        }
    }
    if(idUsuario == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String nomeUsuario = (String) session.getAttribute("nomeUsuario");

    int quizzesCompletados = 0;
    
    // Declarar variáveis para conexões e statements
    Connection connUtilizadores = null;
    Connection connJogos = null;
    Statement stmtUtilizadores = null;
    Statement stmtJogos = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        // Conexão com a base de dados de utilizadores
        connUtilizadores = DriverManager.getConnection("jdbc:mysql://localhost:3306/segura_utilizadores", "root", "!5xne5Qui8900");
        // Conexão com a base de dados de jogos (onde está a tabela Historico)
        connJogos = DriverManager.getConnection("jdbc:mysql://localhost:3306/segura_jogos", "root", "!5xne5Qui8900");
        
        stmtUtilizadores = connUtilizadores.createStatement();
        stmtJogos = connJogos.createStatement();
        
        // Contar quizzes completados pelo usuário (na tabela Historico da base segura_jogos)
        String countQuery = "SELECT COUNT(*) AS total FROM Historico WHERE ID_Utilizador = " + idUsuario + " AND Estado = 'Concluído'";
        ResultSet rsCount = stmtJogos.executeQuery(countQuery);
        if(rsCount.next()){
            quizzesCompletados = rsCount.getInt("total");
        }
        rsCount.close();
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        if(stmtUtilizadores != null) try { stmtUtilizadores.close(); } catch(Exception e) {}
        if(connUtilizadores != null) try { connUtilizadores.close(); } catch(Exception e) {}
        if(stmtJogos != null) try { stmtJogos.close(); } catch(Exception e) {}
        if(connJogos != null) try { connJogos.close(); } catch(Exception e) {}
    }
%>
<!DOCTYPE html>
<html lang="pt-PT">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Histórico - SeguraMente</title>
    <link rel="stylesheet" href="html/css/historico.css">
</head>
<body>
    <div class="container">
        <!-- Sidebar -->
        <div class="sidebar">
            <h1>SeguraMente</h1>
            <a href="dashboard.jsp" class="sidebar-item">
                <img src="html/imagens/jogos_disponiveis_icon.png" alt="Jogos Disponíveis" style="width: 20px; height: 20px;">
                Jogos Disponíveis
            </a>
            <a href="missoes_semanais.jsp" class="sidebar-item">
                <img src="html/imagens/missoes_icon.png" alt="Missões Semanais" style="width: 20px; height: 20px;">
                Missões Semanais
            </a>
            <a href="historico.jsp" class="sidebar-item">
                <img src="html/imagens/historico_icon.png" alt="Histórico" style="width: 20px; height: 20px;">
                Histórico
            </a>
            <a href="logout.jsp" class="sidebar-item" id="logout">
                <img src="html/imagens/logout_icon.png" alt="Sair" style="width: 20px; height: 20px;">
                Sair
            </a>
        </div>

        <!-- Content -->
        <div class="content">
            <!-- Header -->
            <div class="header">
                <div class="search-container">
                    <img src="html/imagens/lupa.png" alt="Lupa" class="search-icon">
                    <input type="text" placeholder="Pesquisar...">
                </div>
                <a href="criar_quizz.jsp" class="create-quiz">Criar Quizz</a>
                <a href="perfil.jsp" class="profile">
                    <img src="html/imagens/avatar.png" alt="Avatar">
                    <span><%= (nomeUsuario != null ? nomeUsuario : "Pessoa") %></span>
                </a>
            </div>

            <!-- Quiz Section (Cabeçalho com informações do usuário) -->
            <div class="quiz-section">
                <div class="quiz-header">
                    <div class="user-info">
                        <img src="html/imagens/avatar.png" alt="Avatar do usuário" class="user-avatar">
                        <div class="user-details">
                            <span class="user-name"><%= (nomeUsuario != null ? nomeUsuario : "Pessoa") %></span>
                            <div class="user-score-container">
                                <img src="html/imagens/flag_icon.png" alt="Flag Icon" class="flag-icon">
                                <div class="user-score">
                                    <span class="score-value"><%= quizzesCompletados %></span>
                                    <span class="score-text">Quiz Passed</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <h2>Histórico</h2>

                <div class="table-container">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Quizz</th>
                                <th>Data</th>
                                <th>Pontuação</th>
                                <th>Perguntas Totais</th>
                            </tr>
                        </thead>
                        <tbody>
<%
    // Consulta para recuperar o histórico do usuário a partir da base "segura_jogos"
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
         Class.forName("com.mysql.cj.jdbc.Driver");
         conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/segura_jogos", "root", "!5xne5Qui8900");
         // A consulta junta a tabela Historico com a tabela Jogo e conta as perguntas por quiz
         String sql = "SELECT h.ID_Historico, j.Nome AS quizName, h.Data, h.Pontuacao_Obtida, " +
                      " (SELECT COUNT(*) FROM Pergunta WHERE ID_Jogo = j.ID_Jogo) AS totalPerguntas " +
                      "FROM Historico h " +
                      "JOIN Jogo j ON h.ID_Jogo = j.ID_Jogo " +
                      "WHERE h.ID_Utilizador = ? " +
                      "ORDER BY h.Data DESC";
         ps = conn.prepareStatement(sql);
         ps.setInt(1, idUsuario);
         rs = ps.executeQuery();
         SimpleDateFormat sdf = new SimpleDateFormat("MMM d, yyyy");
         while(rs.next()){
             int idHistorico = rs.getInt("ID_Historico");
             // Exibe o ID do histórico como rótulo do quiz; você pode substituir por rs.getString("quizName") se preferir
             String quizLabel = "#" + idHistorico;
             java.sql.Date data = rs.getDate("Data");
             int pontuacao = rs.getInt("Pontuacao_Obtida");
             int totalPerguntas = rs.getInt("totalPerguntas");
%>
                            <tr>
                                <td><%= quizLabel %></td>
                                <td><%= sdf.format(data) %></td>
                                <td><%= pontuacao %></td>
                                <td><%= totalPerguntas %></td>
                            </tr>
<%
         }
    } catch(Exception e) {
         out.println("Erro ao carregar histórico: " + e.getMessage());
    } finally {
         if(rs != null) try { rs.close(); } catch(Exception e) {}
         if(ps != null) try { ps.close(); } catch(Exception e) {}
         if(conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>
                        </tbody>
                    </table>
                </div>

                <div class="pagination">
                    <select>
                        <option value="10">10 por página</option>
                        <option value="20">20 por página</option>
                    </select>
                    <div>
                        <span>1 de 1 páginas</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal de Logout -->
    <div class="modal-overlay" id="modal">
        <div class="modal-content">
            <h2>Tem certeza que deseja sair?</h2>
            <div class="modal-buttons">
                <button class="btn-yes" id="confirmYes">Sim</button>
                <button class="btn-no" id="confirmNo">Não</button>
            </div>
        </div>
    </div>

    <script>
        const logoutLink = document.getElementById('logout');
        const modal = document.getElementById('modal');
        const confirmYes = document.getElementById('confirmYes');
        const confirmNo = document.getElementById('confirmNo');

        logoutLink.addEventListener('click', (e) => {
            e.preventDefault();
            modal.classList.add('show');
        });

        confirmYes.addEventListener('click', () => {
            window.location.href = 'logout.jsp';
        });

        confirmNo.addEventListener('click', () => {
            modal.classList.remove('show');
        });
    </script>
</body>
</html>

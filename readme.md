# Desafio Técnico - Gerenciamento de Horários da Escola

Este projeto implementa o banco de dados para uma escola fictícia com o objetivo de:

- Gerenciar departamentos, professores, títulos e disciplinas (matérias).
- Controlar turmas, horários e salas.
- Permitir consultas para saber a quantidade de horas que cada professor tem comprometido em aulas.
- Listar horários livres e ocupados de salas.

---

## Estrutura do Banco

O banco contém as seguintes tabelas:

- **building**: Prédios da escola.
- **room**: Salas dentro dos prédios.
- **department**: Departamentos acadêmicos.
- **title**: Títulos acadêmicos dos professores.
- **professor**: Professores e seus dados.
- **subject**: Disciplinas da escola.
- **subject_prerequisite**: Pré-requisitos entre disciplinas.
- **class**: Turmas vinculadas a professores e disciplinas.
- **class_schedule**: Horários das turmas em salas.

---

## Scripts SQL

O arquivo `escola.sql` contém:

- Comandos para criar as tabelas (caso não existam, remove as antigas).
- Inserção dos dados iniciais de exemplo.
- Duas consultas importantes:

  1. Quantidade de horas que cada professor tem comprometido em aulas.
  2. Lista das salas com horários livres e ocupados, considerando o funcionamento da escola das 08:00 às 17:00 de segunda a sexta.

---

## Como rodar

1. Instale e configure o PostgreSQL e pgAdmin.
2. Crie um banco de dados novo (ex: `escola_desafio`).
3. No pgAdmin, abra o Query Tool e copie todo o conteúdo do arquivo `escola.sql`.
4. Execute o script para criar tabelas, popular dados e executar as consultas.
5. Verifique os resultados nas abas de saída do pgAdmin.

---

## Observações

- Os horários livres consideram intervalos de 1 hora entre 08:00 e 17:00.
- Você pode ajustar os dados no arquivo `escola.sql` para incluir mais professores, turmas e horários.
- O projeto foi feito para fins educacionais e para o desafio técnico solicitado.

---

## Contato

Qualquer dúvida, entre em contato comigo.

Wallan David Peixoto - bobwallan2@gmail.com

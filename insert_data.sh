#!/bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Insérer les équipes dans la table teams
cat games.csv | tail -n +2 | cut -d',' -f3,4 | sort | uniq | while IFS=, read -r winner opponent
do
  # Insérer le gagnant dans la table teams
  $PSQL "INSERT INTO teams (name) VALUES ('$winner') ON CONFLICT (name) DO NOTHING;"
  # Insérer l'opposant dans la table teams
  $PSQL "INSERT INTO teams (name) VALUES ('$opponent') ON CONFLICT (name) DO NOTHING;"
done

# Insérer les matchs dans la table games
cat games.csv | tail -n +2 | while IFS=, read -r year round winner opponent winner_goals opponent_goals
do
  # Récupérer les ids des équipes
  winner_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$winner';")
  opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$opponent';")

  # Supprimer les espaces et nouvelles lignes des résultats de SELECT
  winner_id=$(echo $winner_id | tr -d '[:space:]')
  opponent_id=$(echo $opponent_id | tr -d '[:space:]')

  # Insérer le match dans la table games
  $PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
         VALUES ($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals);"
done

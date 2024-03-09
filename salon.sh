#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ Salon P. Schranz ~~~~~\n"

MAIN_MENU() {
# information text display
if [[ $1 ]]
then
  echo -e "$1"
fi
# get available services
AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")
# if not found
if [[ -z $AVAILABLE_SERVICES ]]
then
  # exit with text
  echo "No service available !"
else 
  # service's choice
  echo What service do you want ?
  echo "$AVAILABLE_SERVICES" | while IFS='|' read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  echo "*) Exit"
  read SERVICE_ID_SELECTED
  # exit with *
  if [[ $SERVICE_ID_SELECTED == '*' ]]
  then
    echo Thanks to stopping in !
    exit
  fi
  # send to service's menu if not number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "I don't understand.\n"
    exit
  fi 
  # verification of the service's choice
  SERVICE_ID_VERIF=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_ID_VERIF ]]
  then
    MAIN_MENU "This service doesn't exist !"
  else
    # get customer info
    echo -e "\nWhat's your phone number ?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    # if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo "What's your name ?"
      read CUSTOMER_NAME
      CUSTOMER_INSERT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi
    # get time
    echo "Hello $CUSTOMER_NAME, what time do you want ?"
    read SERVICE_TIME
    # get informations
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    # creation of appointement
    APPOINTMENT_INSERT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
fi
}

MAIN_MENU
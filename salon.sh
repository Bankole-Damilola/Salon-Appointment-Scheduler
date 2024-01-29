#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~"

MAIN_MENU () {
  
  # Messages to the output
  if [[ $1 ]]
  then
    # Displays when there is an input
    echo -e "\n$1"
  else
    # Displays if no inputs
    echo -e "\nWelcome to My Salon, how can I help you?\n"
  fi

  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    # Print formatted services
    echo "$SERVICE_ID) $SERVICE"

  done

  # get service input
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
  1) USER_REGISTERING 1;;
  2) USER_REGISTERING 2;;
  3) USER_REGISTERING 3;;
  *) MAIN_MENU "I could not find that service. What would you like today?";;
  esac
}

USER_REGISTERING () {
   
   # get customer phone
   echo -e "\nWhat's your phone number?"
   read CUSTOMER_PHONE

   CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

   # if no record
   if [[ -z $CUSTOMER_NAME ]]
   then
     # get the customer name
     echo -e "\nI don't have a record for that phone number, what's your name?"
     read CUSTOMER_NAME

     INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    
   fi

   # get the time for the appointment
   echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
   read SERVICE_TIME

   CONFIRM_APPOINTMENT $1 $SERVICE_TIME $CUSTOMER_PHONE

}

CONFIRM_APPOINTMENT () {

  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$3'")

  # Insert appointment details into the DB
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $1, '$2')")

  # get all the info
  GET_ALL_INFO=$($PSQL "SELECT services.name, time, customers.name FROM appointments INNER JOIN services USING(service_id) INNER JOIN customers USING(customer_id) WHERE service_id = $1 AND customer_id = $CUSTOMER_ID AND time = '$2'")
  echo "$GET_ALL_INFO" | while read SERVICE_NAME BAR TIME BAR CUSTOMER_NAME
  do
    echo -e "\nI have put you down for a $SERVICE_NAME at $TIME, $CUSTOMER_NAME."
  done

}

MAIN_MENU

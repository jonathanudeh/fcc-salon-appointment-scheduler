#!/bin/bash

#declaring psql variable to use in script
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

# greeting
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo "Welcome to My Salon, how can I help you?"

# main menu with list of options to pick from 
MAIN_MENU () {
  # brings out main menu along with the argument given to it when called anywhere
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  #getting list of services we offer right from the database
  SERVICES_RENDERED=$($PSQL "SELECT service_id, name FROM services")
  
  #looping so we can curate the list how we want it to appear
  echo "$SERVICES_RENDERED" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME" 
  done

    #redirects you to the service menu function immediately after the list displays
    SERVICE_MENU
}

SERVICE_MENU () {
  # takes users input
  read SERVICE_ID_SELECTED

  #selects and stores the service id in a variable for use later
  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED AND name IS NOT NULL")
  #selects and stores name of the service picked for later use
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED AND name IS NOT NULL")
  
  #checks if users input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Make sure you picked a number."
  else
    # checking if users input picked is among services rendered
    if [[ -z $SERVICE_ID ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      #if users input is a number and among services rendered then
      echo -e "\nWhat's your phone number?"
      # collects customer's number and use it to search for them in the database
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # if customer not found in database
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        # inserts customers details into the database
        INSERTION_OF_CUSTOMER_NAME=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi

      # if customer is found in the database OR after customer has been added to the database
      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      
      #use customers details to schedule them an appointments by inserting details into appointments table
      APPOINTMENT_SCHEDULER=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      
      #confirmation message yay
      echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi

}

MAIN_MENU

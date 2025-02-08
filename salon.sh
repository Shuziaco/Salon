#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon  --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
# List of services from the database.



# echo "$AVAILABLE_SERVICES"

echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {

    if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
 
  
  
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  # if pick a service that doesn't exist.
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Please enter a valid number"
  else
    SERVICE=$($PSQL "SELECT name from services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      # read phone number of customer
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE 

      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # if customer name doesn't exist
      if [[ -z $CUSTOMER_NAME ]]
      then
        # get new customer name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        # Insert new customer
        INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi

      # get customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      SERVICE_FORMATTED=$(echo $SERVICE |sed 's/^ //')
      # select time slot
      echo -e "\nWhat time would you like your $SERVICE_FORMATTED, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
      read SERVICE_TIME
      
      # Insert time into the appoinments table
      INSERT_TIME=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
     
      echo -e "\nI have put you down for a $SERVICE_FORMATTED at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."

        
    fi
  fi
}
  # else

  #   echo -e "\nWhat's your phone number?"
  #   read PHONE_NUMBER 
MAIN_MENU


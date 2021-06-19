#!/bin/bash

function usage() {
  echo "Usage: bash $0 -z ZIPCODE [ -s SOUND_FILE -r MAIL_RCPT -f GMAIL_MAILFROM -p GMAIL_SMTPAUTH_PASSWORD ]"
}

while getopts ":r:z:s:f:p:h" opt; do
  case ${opt} in
    z) zipcode="$OPTARG"
    ;;
    s) sound_file="$OPTARG"
    ;;
    r) mail_rcpt="$OPTARG"
    ;;
    f) gmail_mail_from="$OPTARG"
    ;;
    p) gmail_smtpauth_password="$OPTARG"
    ;;
    h) usage
       exit
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

gmail_mail_from=${gmail_mail_from:-}
gmail_smtpauth_password=${gmail_smtpauth_password:-}
mail_rcpt=${mail_rcpt:-}
sound_file=${sound_file:-}
zipcode=${zipcode:-}

send_email=false
play_sound=false

## Check vars
if [[ "${zipcode}" = "" ]]; then
  echo "Zipcode not specified!" >&2
  usage
  exit 1
fi

for required_command in curl jq; do
  if ! which ${required_command} >/dev/null 2>&1; then
    echo "Required command '${required_command}' not found!" >&1
    exit 1
  fi
done


if [[ "${mail_rcpt}" != "" && "${gmail_mail_from}" != "" &&  "${gmail_smtpauth_password}" != "" ]]; then
  if ! which sendemail > /dev/null 2>&1; then
    echo "Command 'sendemail' not in path, will not send emails!" >&1
  else
    send_email=true
  fi
else
  echo "Required parameters for sending emails not set, will not send emails!" >&1
fi

if [[ "${sound_file}" != "" && -f "${sound_file}" ]]; then
  if ! which aplay > /dev/null 2>&1; then
    echo "Command 'aplay' not in path, will not play sound!" >&1
  else
    play_sound=true
  fi
else
  echo "Sound file not specified or does not exist, will not play sound!" >&1
fi


mail_subject=Impfterminalarm
slots_free_msg_template="Termin(e) verfuegbar (Anzahl: %s) fuer PLZ: %s, hier geht es zur Anmeldung -> https://www.impfportal-niedersachsen.de/portal/#/appointment/public"
alarm_already_notified=false

tmpfile=$(mktemp)

while true; do
  current_msg="out of stock"
  curl -s https://www.impfportal-niedersachsen.de/portal/rest/appointments/findVaccinationCenterListFree/${zipcode}\?stiko\=\&count\=1 > ${tmpfile}
  if cat ${tmpfile} | jq '.resultList[].outOfStock' | grep -qv "true"; then
    freeSlots=$(cat ${tmpfile} | jq '.resultList[].freeSlotSizeOnline')
    if ${play_sound}; then
      aplay "$sound_file" > /dev/null 2>&1
    fi
    current_msg=$(printf "$slots_free_msg_template" ${freeSlots} ${zipcode})

    if ! ${alarm_already_notified}; then
      if ${send_email}; then
        sendemail -f "${gmail_mail_from}" -u "${mail_subject}" -t "${mail_rcpt}" -s  "smtp.gmail.com:587" -o tls=yes -xu "${gmail_mail_from}" -xp "${gmail_smtpauth_password}" -m "$current_msg"
        alarm_already_notified=true
      fi
    fi
  else
    alarm_already_notified=false
  fi
  echo "$(date) :: $current_msg"
  sleep 1
done


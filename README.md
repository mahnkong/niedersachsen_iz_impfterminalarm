# Terminalarm für Corona - Impfzentrum in Niedersachen

Dieses Git-Repo enthält ein kleines Shell - Script, welches den Nutzer unter Angabe seiner PLZ über freie Termine im entsprechenden Corona - Impfzentrum in Niedersachsen benachrichtigt.
Ich habe dieses Script für micht selber gebaut um schnell eine Benachrichtigung zu bekommen und mir so einen Termin schnappen können. Daher veröffentliche ich es hier um auch anderen Personen zu helfen einen Termin zu ergattern. (andere Suchdienste waren teilweise zu langsam, in meinem LK waren Termine nur gut 30 Sekunden verfügbar)

Benachrichtigungen erfolgen via Terminalausgabe und optional auch via Audio (.wav Files via aplay) oder E-Mail (GMail).

# Benötigte Softwarepakete

**Da ich das Script nur unter Ubuntu bzw. Debian (Raspbian auf RaspberryPi) genutzt habe, kann ich die Pakete nur für diese Systeme benennen)**

Um das Script nutzen zu können, müssen folgende Pakete installiert sein.

- jq
- curl

Für das Abspielen der Sounddatei:

- alsa-utils

Für den Mailversand:

- sendemail
- libio-socket-ssl-perl
- libnet-ssleay-perl

# Verwendung

Das Script kann einfach in der Kommandozeile gestartet werden und läuft bis es abgebrochen wird:

```
bash ./niedersachsen_iz_impfterminalarm.sh -z ZIPCODE [ -s SOUND_FILE -r MAIL_RCPT -f GMAIL_MAILFROM -p GMAIL_SMTPAUTH_PASSWORD ]
```

Zum Starten im Hintergrund kann z.B. das Kommando *nohup* genutzt werden.

## Parameter

- -z: Postleitzahl des Nutzers (muss immer angegeben werden, das zuständige Impfzentrum wird damit ermittelt)
- -s: Sounddatei, wird abgespielt falls freie Termine gefunden werden (z.B. eine der wav - Dateien unter */usr/share/sounds/*)
- -r: E-Mail Adresse, an die Benachrichtigungen über freie Termine versandt werden
- -f: Absendeadresse für die E-Mail Benachrichtigungen (wird auch für Anmeldung an GMail genutzt)
- -p: GMail Passwort für den Versand der E-Mail (Empfehle Verwendung von App - Password, kann im Google - Konto erzeugt werden)

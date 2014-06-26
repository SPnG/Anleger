#!/bin/bash



# Ein leeres PDF Dokument generieren und in alle leeren Patientenverzeichnisse kopieren.
# Nur das klassische pat_nr Schema wird beruecksichtigt. Das Reiz'sche Schema muss zuvor
# konvertiert werden. Hier erfolgt keine Pruefung.
# 
# Als root ausfuehren!
#
# SPnG (FW), Stand: Juni 2014



###########################################################

# Weitere verwendete Praxisbuchstaben ggf. ergaenzen: 
PX=(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)

# Simulation (de)aktivieren: [0/1]
TESTMODUS=1

###########################################################




# ab hier Finger weg...




# Duerfen wir das hier alles?
if [ ! "`id -u`" = "0" ]; then
   echo ""
   echo "ABBRUCH, Rootrechte erforderlich!"
   echo ""
   exit 1
fi

# Log anlegen:
JETZT=`date +%d.%m.%Y\ \-\ \%T\ \%Z`
LOG=`mktemp anleger.XXXXXXXX`
echo ""
echo "Start: $JETZT" | tee -a $LOG

# Simulationsmodus aktiv?
if [ "${TESTMODUS}" = "0" ]; then
   echo "Simulationsmodus ist deaktiviert." | tee -a $LOG
else
   echo "####################################################################" | tee -a $LOG
   echo "SIMULATIONSMODUS IST AKTIV, ES WERDEN KEINE AENDERUNGEN VORGENOMMEN." | tee -a $LOG
   echo "####################################################################" | tee -a $LOG
fi

# Dummy erzeugen:
DUMMY="/tmp/dummydokument"
echo "" >$DUMMY

# Dummydokument nach ps konvertieren:
a2ps -R --media=A4 --columns=1 --header=''\
        --left-title=''\
        --center-title='Dummy'\
        --right-title=''\
        --footer=''\
        --left-footer=''\
        --right-footer=''\
        --pretty-print $DUMMY -o $DUMMY".ps" >/dev/null 2>&1

# nach PDF konvertieren:
ps2pdf -sPAPERSIZE=a4 $DUMMY".ps" $DUMMY".pdf" && echo "Dummy PDF erfolgreich generiert." | tee -a $LOG

#####################################################
# Nur fuer Testzwecke:
#cp $DUMMY".pdf" /home/david/Desktop/Leerdukument.pdf
#####################################################

# in leere Patientenordner einfuegen:
for i in ${PX[@]}; do
   DIR=/home/david/trpword/pat_nr/$i
   # Existiert das jeweilige Praxisverzeichnis?
   if [ -d "$DIR" ]; then
      ZAHL=`find $DIR -empty | wc -l`
      # Wurden hier leere Patientenordner gefunden?
      if [ "${ZAHL}" = "0" ]; then
         PREFIX="    "
         TEXT="keine leeren Ordner vorhanden."
      else
         PREFIX=" -->"
         TEXT="Dummy wird in $ZAHL Patientenordnern einkopiert."
         #find $DIR -empty -exec cp $DUMMY".pdf" {} \;
      fi
      echo "$PREFIX Praxis $i gefunden, $TEXT" | tee -a $LOG
   else
      echo "     Praxis $i nicht in pat_nr vorhanden." | tee -a $LOG
   fi
done

# Rechte neu setzen:
chmod -R 777 /home/david/trpword/pat_nr && echo "Zugriffsrechte in pat_nr gesetzt." | tee -a $LOG
chown -R david:users /home/david/trpword/pat_nr && echo "Besitzrechte in pat_nr gesetzt." | tee -a $LOG

# Aufraeumen:
rm -f $DUMMY* && echo "Temporaere Dateien bereinigt." | tee -a $LOG
JETZT=`date +%d.%m.%Y\ \-\ \%T\ \%Z`
echo "Ende: $JETZT" | tee -a $LOG
cp $LOG /tmp/Anleger.log && chmod 666 /tmp/Anleger.log
rm -f $LOG
echo "Bitte Logdatei unter /tmp/Anleger.log beachten."
echo ""

exit 0

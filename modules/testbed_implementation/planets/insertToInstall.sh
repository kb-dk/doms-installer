cp $BASEDIR/data/planets/planets.tgz $TESTBED_DIR
pushd $TESTBED_DIR > /dev/null
tar -xzf planets.tgz
cd planets/server

#tomcat ports
grep -l -R 8080 * | grep \\.xml |  grep -v \/tmp\/ | grep '/deploy/\|/conf/' \
| xargs -I '{}' \
 sed -i \
 -e 's|8080|'"$PLANETS_8080PORT"'|g' \
  '{}'

grep -l -R 8443 * | grep \\.xml |  grep -v \/tmp\/ | grep '/deploy/\|/conf/' \
| xargs -I '{}' \
 sed -i \
 -e 's|8443|'"$PLANETS_8443PORT"'|g' \
  '{}'

grep -l -R 8009 * | grep \\.xml |  grep -v \/tmp\/ | grep '/deploy/\|/conf/' \
| xargs -I '{}' \
 sed -i \
 -e 's|8009|'"$PLANETS_8009PORT"'|g' \
  '{}'

grep -l -R 3873 * | grep \\.xml |  grep -v \/tmp\/ | grep '/deploy/\|/conf/' \
| xargs -I '{}' \
 sed -i \
 -e 's|3873|'"$PLANETS_3873PORT"'|g' \
  '{}'

grep -l -R 8093 * | grep \\.xml |  grep -v \/tmp\/ | grep '/deploy/\|/conf/' \
| xargs -I '{}' \
 sed -i \
 -e 's|8093|'"$PLANETS_8093PORT"'|g' \
  '{}'

grep -l -R 8083 * | grep \\.xml |  grep -v \/tmp\/ | grep '/deploy/\|/conf/' \
| xargs -I '{}' \
 sed -i \
 -e 's|8083|'"$PLANETS_8083PORT"'|g' \
  '{}'

grep -l -R 1099 * | grep \\.xml |  grep -v \/tmp\/ | grep '/deploy/\|/conf/' \
| xargs -I '{}' \
 sed -i \
 -e 's|1099|'"$PLANETS_1099PORT"'|g' \
  '{}'

grep -l -R 1098 * | grep \\.xml |  grep -v \/tmp\/ | grep '/deploy/\|/conf/' \
| xargs -I '{}' \
 sed -i \
 -e 's|1098|'"$PLANETS_1098PORT"'|g' \
  '{}'

grep -l -R 4444 * | grep \\.xml |  grep -v \/tmp\/ | grep '/deploy/\|/conf/' \
| xargs -I '{}' \
 sed -i \
 -e 's|4444|'"$PLANETS_4444PORT"'|g' \
  '{}'

grep -l -R 4445 * | grep \\.xml |  grep -v \/tmp\/ | grep '/deploy/\|/conf/' \
| xargs -I '{}' \
 sed -i \
 -e 's|4445|'"$PLANETS_4445PORT"'|g' \
  '{}'

grep -l -R 4446 * | grep \\.xml |  grep -v \/tmp\/ | grep '/deploy/\|/conf/' \
| xargs -I '{}' \
 sed -i \
 -e 's|4446|'"$PLANETS_4446PORT"'|g' \
  '{}'

#grep -l -R INSTALLDIRPLACEHOLDER * | grep \\.xml |  grep -v \/tmp\/ | grep '/deploy/\|/conf/' \
#| xargs -I '{}' \
# sed -i \
# -e 's|INSTALLDIRPLACEHOLDER|'"$TESTBED_DIR/planets"'|g' \
#  '{}'


#Fix the fragging jackrabbit planets component, with its encoded 1099 port
cd default/deploy
mkdir zip
mv jackrabbit-jcr-rmi.jar zip
cd zip
unzip jackrabbit-jcr-rmi.jar
rm -rf jackrabbit-jcr-rmi.jar
grep -l -R 1099 * | grep \\.xml \
| xargs -I '{}' \
 sed -i \
 -e 's|1099|'"$PLANETS_1099PORT"'|g' \
  '{}'
zip -r jackrabbit-jcr-rmi.jar org/ META-INF/ jackrabbit-rmi-service.xml
mv jackrabbit-jcr-rmi.jar ..
cd ..
rm -rf zip
popd > /dev/null

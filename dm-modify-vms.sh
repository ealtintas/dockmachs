#!/bin/bash

SLEEP=1

case "${HOSTNAME}" in
    "k1")
# k1 swarm workers
	# wrk201
	# wrk221
	# wrk241
    WORKERS="wrk194 wrk195 wrk196 wrk197 wrk198 wrk199 wrk200 wrk202 wrk203 wrk204 wrk205 wrk206 wrk207 wrk208 wrk209 wrk210 wrk211 wrk212 wrk213 wrk214 wrk215 wrk216 wrk217 wrk218 wrk219 wrk220 wrk222 wrk223 wrk224 wrk225 wrk226 wrk227 wrk228 wrk229 wrk230 wrk231 wrk232 wrk233 wrk234 wrk235 wrk236 wrk237 wrk238 wrk239 wrk240 wrk242 wrk243 wrk244 wrk245 wrk246 wrk247 wrk248 wrk249 wrk250 wrk251 wrk252 wrk253 wrk254"
	;;
    "k2")
# k2 swarm workers
	# wrk131
	# wrk151
	# wrk171
    WORKERS="wrk130 wrk132 wrk133 wrk134 wrk135 wrk136 wrk137 wrk138 wrk139 wrk140 wrk141 wrk142 wrk143 wrk144 wrk145 wrk146 wrk147 wrk148 wrk149 wrk150 wrk152 wrk153 wrk154 wrk155 wrk156 wrk157 wrk158 wrk159 wrk160 wrk161 wrk162 wrk163 wrk164 wrk165 wrk166 wrk167 wrk168 wrk169 wrk170 wrk172 wrk173 wrk174 wrk175 wrk176 wrk177 wrk178 wrk179 wrk180 wrk181 wrk182 wrk183 wrk184 wrk185 wrk186 wrk187 wrk188 wrk189 wrk190"
	;;
    *)    WORKERS="Default";;
esac

for HOST in ${WORKERS}
do

#   MYCMD="VBoxManage modifyvm ${HOST} --cpus 1 --memory 2000"
  MYCMD="VBoxManage modifyvm ${HOST} --memory 1800"
  echo "I will stop ${HOST} in ${SLEEP} seconds. Than that I will run: ${MYCMD} and restart it."

  sleep ${SLEEP}
  echo "Stopping ${HOST} ..."
  docker-machine stop ${HOST}
  echo "If cant stop, try killing ${HOST} ..."
  docker-machine kill ${HOST}

  sleep ${SLEEP}
  echo "Runnig: ${MYCMD}"
  ${MYCMD}

  sleep ${SLEEP}
  echo "Starting ${HOST} with new settings..."
  docker-machine start ${HOST} &
done

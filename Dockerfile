FROM lucaslsl/passenger

# Set correct environment variables.
ENV HOME /root
ENV APP_DIR /home/app

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

RUN apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install libpq-dev python-dev python-imaging

# Enable nginx and passenger
RUN rm -f /etc/service/nginx/down

# Tell passenger about node app
RUN rm /etc/nginx/sites-enabled/default
ADD app.conf /etc/nginx/sites-enabled/app.conf


# Add the sails app
COPY ./app ${APP_DIR}

# Build app
WORKDIR ${APP_DIR}
RUN pip install -r requirements.txt

# Change owner of app files to app (UID 999) (app.js is run by passenger as whatever its owner is)
RUN chown -R 9999 /${APP_DIR}
RUN chown -R 9999 ${APP_DIR}/public


# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
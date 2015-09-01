# FROM lucaslsl/passenger
FROM phusion/passenger-customizable:0.9.17

RUN apt-get update && apt-get install -y \
	python \
	python-pip \
	python-dev \
	libjpeg-dev \
	libpq-dev \
	nodejs

RUN ln -sf /usr/bin/nodejs /usr/bin/node	


RUN mkdir /home/app/mytest

# Set correct environment variables.
ENV HOME /root
ENV APP_DIR /home/app/mytest

# Add the sails app
COPY ./app ${APP_DIR}

# Build app
WORKDIR ${APP_DIR}
RUN pip install -r requirements.txt


# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

#RUN apt-get -y install libpq-dev python-dev python-imaging zlib1g-dev libfreetype6-dev #liblcms2-dev libwebp-dev libtiff5-dev libjpeg8-dev

# Enable nginx and passenger
RUN rm -f /etc/service/nginx/down

# Tell passenger about node app
RUN rm /etc/nginx/sites-enabled/default
ADD app.conf /etc/nginx/sites-enabled/app.conf


# Change owner of app files to app (UID 999) (app.js is run by passenger as whatever its owner is)
RUN chown -R 9999 /${APP_DIR}
RUN chown -R 9999 ${APP_DIR}/public


# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
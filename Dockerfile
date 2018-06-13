FROM ruby:2.5.1

ENV LANG C.UTF-8

# Install dependencies.
#
# build-essential       - To ensure certain gems can be compiled.
# libpq-dev             - Communicate with postgres through the postgres gem.
# postgresql-client     - In case of direct access to PostgreSQL,
#                         e.g. `rake db:structure:load` depends on psql.
RUN apt-get update \
    && apt-get install -y \
                       --no-install-recommends \
                       build-essential

# Create an unprivileged user, prosaically called app, to run the app inside
# the container. If you don’t do this, then the process inside the container
# will run as root, which is against security best practices and principles.
RUN useradd --user-group \
            --create-home \
            --shell /bin/false \
            app

ENV HOME=/home/app
WORKDIR $HOME

USER app

COPY --chown=app:app Gemfile \
                     Gemfile.lock \
                     ptt.gemspec \
                     $HOME/
COPY --chown=app:app lib/ptt/version.rb \
                     $HOME/lib/ptt/
RUN bundle install --jobs=20 \
                   --clean

COPY --chown=app:app . $HOME/

CMD ["irb"]

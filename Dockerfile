FROM alpine:edge

ADD start.sh /start.sh
RUN chmod +x /start.sh

CMD /start.sh

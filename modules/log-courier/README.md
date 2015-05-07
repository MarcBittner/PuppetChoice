# Log-Courier
[Log-courier](https://github.com/driskell/log-courier) is a lightweight agent that's meant to run on any server that wants to send logs to the Choice ElasticSearch-Logstash-Kibana (ELK) log aggregation service.  It is a better-maintained fork of logstash-forwarder.

This puppet module installs the log-courier.  Note that you must manually run log-courier for now.

## Configuring `log-courier` on a Server

Before you run log-courier, you need to configure it.  Configuration is simple.  Either edit and paste or copy on of the config/[appserver|webserver|cassandra]/log-courier.conf files to /etc/log-courier/log-courier.conf

  ```
  vim /etc/log-courier/log-courier.conf
  ```

  You will only need to change the `files` stanza of this file.  Set a path for each file you wish to send to the ELK cluster,
  and also be sure to set the `type`.

### What is `type`?

The `type` variable is how the ELK cluster identifies one app's logs from another.  On the ELK cluster, we will have a configuration that looks for a certain `type` and parses logs accordingly.  Note that the ELK cluster can use RegEx's so for production, we can come up with standards for our `type`'s.  For example, `"type": "reservationMobileNotification-apache"`

### Gotcha's

The directory from which you run log-courier will create a `.log-courier` file that keeps track of which files have been sent so far.  If you ever need to "re-send" log files that log-courier thinks have already been sent, you can simply edit this file.  Note that running the `log-courier` daemon from a different directory will create a new `.log-courier` file.

## Manually Running `log-courier`
We are finally ready to run log-courier.  If all the above steps have completed successfully, type:

```
/etc/init.d/log-courier start
```

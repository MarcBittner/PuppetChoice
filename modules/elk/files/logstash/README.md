# Adding New Log Sources to Logstash

At some point, we will want to begin importing a new source of logs (e.g. a new Java application that generates log files) into our ELK cluster.  To do so, follow the steps below.

## Background on How the ELK Stack Works
Our ELK cluster is made up of 2 or more individual ELK EC2 instances.  An ELK EC2 instance, in turn, has running on it *Elasticsearch*, *Logstash*, and *Kibana*.  

Elasticsearch is a NoSQL data store that stores all the log data.  Elasticsearch automatically distributes its data across every EC2 instance ("node") in the cluster.  

Logstash is a daemon whose job is to take in log data from a variety of sources, parse it, and output it to Elasticsearch.

Kibana is a web interface for visualizing data contained in Elasticsearch.  It obtains its data by directly querying Elasticsearch.

For more on the ELK cluster, see [Choice Hotels Log Aggregation Service](NEED-URL) *NEED-URL*.

## Set Up a New Log Source
*1. Setup the `log-courier` agent on the new log source.*

  This may already be done for you thanks to Convention over Configuration.  For more details, see [Setting Up Log-Courier on a New App](NEED-URL) *NEED-URL*.

  Pay special attention to the `type` field in the `log-courier` configuration.  The `type` field does not hold any special meaning in Logstash.  Rather, it is meaningful because we have configured Logstash to parse incoming log files differently depending on the value of the `type` field.  This choice is a common convention in the ELK community.

*2. Tell Logstash how to parse the new log source.*

  Now update the file `/elk/logstash/config/100-input-logCourier.conf`.  This file has two stanzas, `input` and `filter`.  The `input` stanza tells Logstash what port to listen on and specifies SSL keys.  No change is needed here.

  The `input` stanza is where we will do our work.  First, decide if your new application is just another instance of an application category whose logs we already parse.  For example, are you onboarding a Tomcat application?  The following code indicates we already accept these logs:

  ```
  # TOMCAT
  # ----------------------------------------------------------------------------
  if [type] =~ /-tomcat$/ {
  ```

  Notice our friend `type` has shown up again.  The above expression returns a boolean (true/false) if the value of the `type` field received by Logstash matches the given regular expression (in this case, "ends with `-tomcat`").

  If this regular expression is true, the remainder of this stanza is processed:

  ```
  if [type] =~ /-tomcat$/ {
    multiline {
      pattern => "^%{TOMCAT_DATESTAMP}"
      negate => true
      what => "previous"
    }
    grok {
      #match => [ "message", "(?m)%{TOMCAT_DATESTAMP:raw-timestamp} %{LOGLEVEL:level} %{JAVACLASSANDMETHOD:class-and-method} - %{JAVALOGMESSAGE:log-message}\n%{JAVACLASS:exception}:\n%{JAVASTACKTRACEPART:exception_stack_trace}" ]
      match => [ "message", "(?m)%{TOMCAT_DATESTAMP:raw-timestamp} %{LOGLEVEL:level} %{JAVACLASSANDMETHOD:class-and-method} - %{JAVALOGMESSAGE:log-message}\n%{JAVACLASS:exception}:.*" ]
    }
    date {
      match => [ "raw-timestamp", "YYYY-MM-dd HH:mm:ss" ]
    }
  ```

  Note that because our new log source is a Choice tomcat app and adheres to the logging recommendations documented in the `log-courier` documentation, there is nothing more for us to do other than to begin sending logs over and verify they are being parsed correctly!

  If, however, you are onboarding a new log source, then you'll need to create a new stanza with a new regular expression, and a new set of declarations on how Logstash should filter the incoming log data.

  To do this, copy & paste an existing stanza, and then take special care to edit the *filter*'s to match your new log source.  How do you do this?  Check out the "filters" section of the official Logstash documentation: http://logstash.net/docs/1.4.2/.

  Be sure to check out the [date filter](http://logstash.net/docs/1.4.2/filters/date), [grok filter](http://logstash.net/docs/1.4.2/filters/grok), and [multiline filter](http://logstash.net/docs/1.4.2/filters/multiline) as these are the most important.

  To help get you started...

  - The "date filter" converts a given field into a date format that is known to Elasticsearch.  This allows us to order log files according to the datestamp in the log file, not the order in which we receive them.
  - The "grok filter" parses an unstructured log file into a structured set of data according to a set of regular expressions that are defined in `/elk/logstash/grok-patterns`.
  - The "multiline filter" tells Logstash that a single log entry may span multiple lines.  You shouldn't need to change this setting, except to update the `pattern` key.

### Making Your Life 100x Easier with GrokDebug

When you begin parsing a new log source, you'll quickly see that it's hard to establish a nice develoepr feedback loop where you try a grok configuration, see if it works, and then tweak accordingly.

Instead of using Logstash itself for your feedback loop, I strongly encourage you to try https://grokdebug.herokuapp.com/.  Be sure to load the `grok-patterns` file in the "Custom patterns" box, then just copy & paste the relevant lines.

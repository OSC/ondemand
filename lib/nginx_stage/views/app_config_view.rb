module NginxStage
  # A view used as context for the app config ERB template file
  module AppConfigView
    # The URI used to access the app from the browser
    # @return [String] the app URI
    def app_request_uri
      "#{sub_uri}#{NginxStage.app_request_uri(env: env, owner: owner, name: name)}"
    end

    # Path to the app root on the local filesystem
    # @return [String] path to app root
    def app_root
      NginxStage.app_root(env: env, owner: owner, name: name)
    end

    # The Passenger environment to run app under
    # @return [String] Passenger app environment
    def app_passenger_env
      NginxStage.app_passenger_env(env: env, owner: owner, name: name)
    end

    # The token used to identify an app
    # @return [String] unique app token
    def app_token
      NginxStage.app_token(env: env, owner: owner, name: name)
    end

    # URI used to access filesystem from the browser
    # @return [String] the filesystem URI
    def download_uri
      "#{sub_uri}#{NginxStage.pun_download_uri}" if NginxStage.pun_download_uri
    end

    # Path to the filesystem root where files are served from
    # NB: Need to use a regular expression for user as this will be in a global
    # app config that all users share
    # @return [String] path to filesystem root
    def download_root
      NginxStage.pun_download_root(user: "[\w-]+")
    end

    # Wether the sys admin opts in to metrics collection
    # @return [Boolean] whether metrics should be collected
    def opt_in_metrics
      NginxStage.opt_in_metrics
    end

    # Have all apps phone home for analytics (required by OOD proposal)
    # @return [String] google analytics script
    def google_analytics
      <<-EOF.gsub("'", %q{\\\'})
        <script>
          (function() {
            (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
            (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
            m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
            })(window,document,'script','https://www.google-analytics.com/analytics.js','_gaOodMetrics');

            // polyfill for older browsers
            if (!Date.prototype.toISOString) {
              (function() {
                function pad(number) {
                  if (number < 10) {
                    return '0' + number;
                  }
                  return number;
                }

                Date.prototype.toISOString = function() {
                  return this.getUTCFullYear() +
                    '-' + pad(this.getUTCMonth() + 1) +
                    '-' + pad(this.getUTCDate()) +
                    'T' + pad(this.getUTCHours()) +
                    ':' + pad(this.getUTCMinutes()) +
                    ':' + pad(this.getUTCSeconds()) +
                    '.' + (this.getUTCMilliseconds() / 1000).toFixed(3).slice(2, 5) +
                    'Z';
                };
              }());
            }

            var uniqueId = function() {
              return new Date().getTime() + '.' + Math.random().toString(36).substring(5);
            };

            _gaOodMetrics('create', 'UA-79331310-2', 'auto', {
              'cookieName': '_gaOodMetrics'
            });
            _gaOodMetrics('set', 'anonymizeIP', 'true');
            _gaOodMetrics('set', 'userId', '$http_x_forwarded_user');
            _gaOodMetrics('set', 'dimension1', '#{app_token}'); // AppName
            _gaOodMetrics('set', 'dimension2', '$http_x_forwarded_user'); // UserName
            _gaOodMetrics('set', 'dimension3', '$http_x_forwarded_proto://$http_x_forwarded_host'); // HostName
            _gaOodMetrics('set', 'dimension4', uniqueId()); // Session ID
            _gaOodMetrics('set', 'dimension5', new Date().toISOString()); // Timestamp
            _gaOodMetrics('set', 'dimension6', '$http_x_forwarded_user'); // User ID
            _gaOodMetrics('send', 'pageview');
          })();
        </script>
      EOF
    end
  end
end

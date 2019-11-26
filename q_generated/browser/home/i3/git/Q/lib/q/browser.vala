

namespace Q {
  namespace Browser {
    public const string HOME_URL = "http://google.com";
    public const string DEFAULT_PROTOCOL = "http";

    public static string omni(string url) {
      string?[] _q_local_scope_empty_str_array = new string[0];
      MatchInfo _q_local_scope_match_data = null;

      string u; u = "";
      u = url;

      if (!((/.*:\/\/.*/).match(u, 0, out _q_local_scope_match_data))) {

        if (!((/\./).match(u, 0, out _q_local_scope_match_data))) {
          u = @"google.com/search?q=$(string.joinv("+", url.split(" ")))";

        };
        if ((/ /).match(u, 0, out _q_local_scope_match_data)) {
          u = @"google.com/search?q=$(string.joinv("+", url.split(" ")))";
        }

        u = @"$(Browser.DEFAULT_PROTOCOL)://$(u)";

      };
      return (u);

    }

  }

}

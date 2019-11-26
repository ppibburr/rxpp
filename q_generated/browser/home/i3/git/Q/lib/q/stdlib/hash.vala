namespace Q {

  public class Hash<T> : HashTable<string?, T> {
public Hash () {
      base.full(str_hash, str_equal, null, null);

    }

        public  string[] keys {
        owned get {

          return (get_keys_as_array());

        }


      }
  }


}

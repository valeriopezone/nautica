import 'package:nautica/SignalKClient.dart';

class MetaFetcher{
  SignalKClient client = null;

  MetaFetcher(this.client){
    //check connection status

  }


  Future<dynamic> getMetaData(String path){
  if(this.client != null && this.client.loaded){
    //get data
    this.client.execHTTPRequest(path:path).then((response){

      String units = '-';
      String description = '-';

      if(response['meta']['units'] != null){
          units = response['meta']['units'];
      }

      if(response['meta']['description'] != null){
        description = response['meta']['description'];
      }

      return {'units' : units, 'description' : description};

    });

  }
  }
}
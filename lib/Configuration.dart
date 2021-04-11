

class Authentication {
  Authentication(this.username,this.password);
  String username = "";
  String password = "";
}

const Map NAUTICA =  {
  'application':  {'debug': true},
  'signalK':  {'APIVersion': 'v1',
  'connection':
  {
    'address' : '192.168.1.180',
    'port' : 3001
  }},
  'configuration' : {
    'widget' : {
      'refreshRate' : 350 //ms
    },
    'map' : {
      'refreshRate' : 2 //s
    },
    'connection' : {
      'timeout' : 2 //s
    }
  }
};


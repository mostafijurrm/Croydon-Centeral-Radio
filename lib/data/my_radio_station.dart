class MyRadioStation {
  final String id;
  final String city_id;
  final String cat_id;
  final String name;
  final String radio_url;
  final String image;
  final String description;

  const MyRadioStation({this.id, this.city_id, this.cat_id, this.name, this.radio_url, this.image, this.description});
}

class MyRadioStationList {
  static List<MyRadioStation> list() {
    const data = <MyRadioStation> [
      MyRadioStation(
        id: '1',
        city_id: '10',
        cat_id: '100',
        name: 'Classic Reggae',
        radio_url: 'https://radio.openview24.com/radio/8110/radio.mp3',
        image: 'assets/image/stations/1.png',
          description: 'Feel The Music'
      ),
      MyRadioStation(
          id: '2',
          city_id: '20',
          cat_id: '200',
          name: 'Dancehall Raw',
          radio_url: 'https://radio.openview24.com/radio/8060/radio.mp3',
          image: 'assets/image/stations/2.png',
        description: 'Feel The Music'
      ),
      MyRadioStation(
          id: '3',
          city_id: '30',
          cat_id: '300',
          name: 'Mega Hits Station',
          radio_url: 'https://radio.openview24.com/radio/8070/radio.mp3',
          image: 'assets/image/stations/3.png',
          description: 'Feel The Music'
      ),
      MyRadioStation(
          id: '4',
          city_id: '40',
          cat_id: '400',
          name: 'Soca City',
          radio_url: 'https://radio.openview24.com/radio/8020/radio.mp3',
          image: 'assets/image/stations/4.png',
          description: 'Feel The Music'
      ),
      MyRadioStation(
          id: '5',
          city_id: '50',
          cat_id: '500',
          name: 'Slow Jams/RnB Station',
          radio_url: 'https://radio.openview24.com/radio/8030/radio.mp3',
          image: 'assets/image/stations/5.png',
          description: 'Feel The Music'
      ),
      MyRadioStation(
          id: '6',
          city_id: '60',
          cat_id: '600',
          name: 'Dance Nation',
          radio_url: 'https://radio.openview24.com/radio/8040/radio.mp3',
          image: 'assets/image/stations/6.png',
          description: 'Feel The Music'
      ),
      MyRadioStation(
          id: '7',
          city_id: '70',
          cat_id: '700',
          name: 'Reggae On The City',
          radio_url: 'https://radio.openview24.com/radio/8010/radio.mp3',
          image: 'assets/image/stations/7.png',
          description: 'Feel The Music'
      ),
      MyRadioStation(
          id: '8',
          city_id: '80',
          cat_id: '800',
          name: 'Hip-Hop Station',
          radio_url: 'https://radio.openview24.com/radio/8100/radio.mp3',
          image: 'assets/image/stations/8.png',
          description: 'Feel The Music'
      ),
      MyRadioStation(
          id: '9',
          city_id: '90',
          cat_id: '900',
          name: 'Dancehall Rave',
          radio_url: 'https://radio.openview24.com/radio/8050/radio.mp3',
          image: 'assets/image/stations/9.png',
          description: 'Feel The Music'
      ),
      MyRadioStation(
          id: '10',
          city_id: '100',
          cat_id: '1000',
          name: 'Smooth Jazz',
          radio_url: 'https://radio.openview24.com/radio/8090/radio.mp3',
          image: 'assets/image/stations/10.png',
          description: 'Feel The Music'
      ),
      MyRadioStation(
          id: '11',
          city_id: '1100',
          cat_id: '11000',
          name: 'Croydon Central Live',
          radio_url: 'https://radio.openview24.com/radio/8120/radio.mp3',
          image: 'assets/image/stations/11.png',
          description: 'Feel The Music'
      ),
    ];
    return data;
  }
}
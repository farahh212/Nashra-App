
import 'package:flutter/material.dart';
import 'package:nashra_project2/models/index.dart';
import 'package:nashra_project2/screens/ad_card.dart';
import 'package:nashra_project2/services/advertisement_services.dart';

class AdvertisementScreen extends StatelessWidget{
  final  AdvertisementServices _advertisementServices = AdvertisementServices();

  @override  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(title: Text("Advertisement")),
      body: FutureBuilder<List<Advertisement>>(future:_advertisementServices.getApprovedAdvertisements(),
       builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(child: CircularProgressIndicator());
        }else if(snapshot.hasError){
          return Center(child: Text("Error loading ads."));
       }else if(!snapshot.hasData ||  snapshot.data!.isEmpty){
          return Center(child: Text("No ads available."));
        }else{
          final ads = snapshot.data!;
          return ListView.builder( 
          itemCount: ads.length,
          itemBuilder: (Context, index)=> AdCard(ad: ads[index]),);
       }
       },
       ),
       floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to ad submission form
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.language), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
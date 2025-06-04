import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FollowingTabview extends StatefulWidget {
  const FollowingTabview({super.key});

  @override
  State<FollowingTabview> createState() => _FollowingTabviewState();
}

class _FollowingTabviewState extends State<FollowingTabview> {
  @override
  Widget build(BuildContext context) {
     String truncateUsername (String username , {int maxChars = 3}){
      if(username.length <= maxChars){
        return username;
      }
      else{
        return username.substring(0 , maxChars) + '...';
      }
    }
  String formatPostgresTimestamp(String timestamp) {
  // Parse the timestamp string to DateTime
  DateTime date = DateTime.parse(timestamp);

  // Format as "May 19 24"
  return DateFormat('MMM d yy').format(date);
}

    
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 16),
        child: ListTile(
          // Profile avatar
          leading: CircleAvatar(
            backgroundImage: ExactAssetImage('assets/images/pngwing.com.png'),
            radius: 20,
          ),

          // Title and subtitle column
          title: Row(
            children: [
              Text(
                'Government of Iraq',
                style: TextStyle(fontSize: 14,   fontFamily: "bOLD") ,
              ),
              const SizedBox(width: 6),
              Text(
                truncateUsername('@allahbillah'),
                style: TextStyle(fontSize: 12, fontFamily: "rEGULAR", color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 12),
              Padding(
                padding : EdgeInsets.only(bottom : 2 ),
                child: Text(
                  'May19 24',
                  style: TextStyle(fontSize: 13, fontFamily: "rEGULAR"),
                ),
              ),
                            const SizedBox(width: 12),

              Icon(Icons.more_vert, size: 13, ),
            ],
          ),

          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Prime Minister Mohammed arrived in the capital, Baghdad. after concluding his two-day official visit to the Islamic Republic of Iran, where he had several meetings and talks.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              // Action buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.chat_bubble_outline, ),
                  SizedBox(width: 4),
                  Text('3', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 32),
                  Icon(Icons.repeat, ),
                  SizedBox(width: 4),
                  Text('2', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 32),
                  Icon(Icons.favorite, ),
                  SizedBox(width: 4),
                  Text('8', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 32),
                  Icon(Icons.bookmark),
                  SizedBox(width: 30),
                  Icon(Icons.share, ),
                ],
              ),
            ],
            
          ),
          isThreeLine: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

  
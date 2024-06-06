import 'package:flutter/material.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDFA),
      appBar: AppBar(
          title: const Text(
            "About", style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700
          ),)
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: SafeArea(
            child: Text('''Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec tristique ut arcu ultrices suscipit. Nam lobortis lacinia dui sed auctor. Nulla vestibulum mauris ut velit imperdiet vehicula. Nulla dapibus odio velit, eu ornare libero aliquet ac. Proin eget massa et purus pellentesque elementum vel nec enim. Donec vel vulputate eros, id convallis dui. Phasellus porta, libero non mollis fermentum, lacus sem dapibus tellus, quis faucibus nulla mi quis ipsum. Curabitur pharetra maximus imperdiet. Etiam eget iaculis ligula. Sed condimentum, massa sit amet dignissim fermentum, urna sapien pulvinar lorem, id rhoncus elit justo quis lorem. Duis lobortis convallis dictum.

Maecenas feugiat porttitor purus et blandit. Nulla ultricies accumsan erat sed cursus. Proin nec aliquam risus, ac pellentesque risus. Curabitur porttitor justo augue, id cursus eros euismod feugiat. Donec sem nulla, consequat non tincidunt ac, tempus vitae metus. Aenean laoreet at neque quis pretium. Praesent ornare arcu non condimentum pharetra. Vestibulum efficitur dui ac nulla elementum porttitor. Nullam tristique lorem at sagittis tempus. Nullam in ante tortor. Donec nec lorem quis nunc sagittis ultrices.

Nullam vitae orci posuere, pellentesque arcu ut, tincidunt libero. Phasellus tristique, risus ut sollicitudin varius, augue ex malesuada velit, ut tempus massa felis sed nunc. Proin et erat eu purus feugiat dapibus eget non risus. Donec rhoncus ut eros sed aliquam. Suspendisse dictum nulla et risus luctus, eget placerat massa congue. Morbi hendrerit massa eu commodo hendrerit. Pellentesque non pulvinar turpis, vitae consectetur purus. Aliquam euismod, velit ac condimentum congue, augue nulla vestibulum tellus, ac mollis nisi massa eget dui. Nullam et est ut enim auctor auctor. Curabitur faucibus porttitor viverra. Cras tempus quam et augue malesuada, sed hendrerit ipsum rhoncus. Ut imperdiet consectetur lectus ut hendrerit. In felis ex, varius eget mattis in, posuere nec nisl. Sed placerat urna vel lacus sollicitudin dapibus nec a risus. Sed fermentum et dolor a ultrices.'''),
        ),
      )
    );
  }
}

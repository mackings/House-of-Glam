import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hog/components/categoryslider.dart';
import 'package:hog/components/header.dart';
import 'package:hog/components/search.dart';
import 'package:hog/components/slideritem.dart';
import 'package:hog/components/sliders.dart';


class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {

  TextEditingController searchController = TextEditingController();


  @override
void initState() {
  super.initState();
  searchController = TextEditingController();
}

@override
void dispose() {
  searchController.dispose();
  super.dispose();
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20), // add nice spacing
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header(
                userName: "Mac Kingsley",
                avatarUrl: "https://i.pravatar.cc/150?img=3",
                onNotificationTap: () {
                  print("Notifications tapped!");
                },
              ),
              const SizedBox(height: 20),
              
CustomSearchBar(
  controller: searchController,
  hintText: "Search item",
  onChanged: (value) => print("Search: $value"),
  onFilterTap: () => print("Filter tapped!"),
),

const SizedBox(height: 30),

CarouselSlider(
  height: 180,
  items: const [
CarouselItemWidget(
          title: "Agbada",
          imageUrl: "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBxAQEhAQDw8PDxAQEBAQDw8PDw8ODw8VFRUXFxUVFxUYHSggGBolGxUVITIhJSkrLi4uFx8zODMsNygtLisBCgoKDg0OGxAQGi0lHyUtKy01LS0tLS0tKy8rLS0tLSstLS0tLS0tLS0tKy0tLS0tLS0tKy0tLS0vLS0tLS0tLf/AABEIAPsAyQMBIgACEQEDEQH/xAAbAAABBQEBAAAAAAAAAAAAAAABAAIDBAUGB//EAEQQAAEEAAQCCAMEBQoHAQAAAAEAAgMRBBIhMUFRBQYTImFxgZEyobEjQlLBFDNictEHJGOCkqKy0uHwFUNEg6PC8TT/xAAaAQACAwEBAAAAAAAAAAAAAAAAAQIEBQMG/8QAKxEAAgIBBAAEBQUBAAAAAAAAAAECEQMEEiExBUFRYSIycZHRE4GxwfCh/9oADAMBAAIRAxEAPwDDCISCIWGepHBOCATggYQE4BIJwSAQTgEAnhACpGkgnIGBFJFAASTqRpIY2kqTqSpADaSpOpOpAEdJUn0hSAG0lSfSVIGR0lSfSVIEMpKk6kqQBmBGkgipEBwTgmhOCQxwT00JyACE4JoTwkMcEaQCcAgAUiE6kAEDCEaSRSAFIJ6FIACKVI0gYEqRpKkABJGkqTAFIUnUlSAGUlSclSQGSEUAnKZzCE8JgT2pDHBOTQnBADgnhMCeEhjgnIBPQMZLI1jS57g1rRbnONADxK5bE9cRne2GNrmjRj3Fwzczl5eCzeufSjpJTC0ns4jRA2c/iTzrb0K55rVo4NLGt0/Mx9VrpbtuPivM6MdY8VmzdqK/Bkbk8ufzXQdF9ZopKbL9k/mf1ZPnw9fdcNG690+uSsT02Oaqq+hVxazLB3d/U9UHulS4ToDph2HcGvLjCTTmmyG395v8Buu8Y4EAtIIIBBGxB2Ky82B4nT6NrTamOaNrv0FSNIhFcSyNpJOpCkACkkUkACkqRRpADEk4hCkDMYJwQCIUzkORagnNSGEJ4QATgEAOTgmgJ4SGOanhNCUmzq3o17IA8jxUmaSRwunyPdR1OrifzTmHmPZQRnbyCtRFb6PKt27JYqO3sp2tUYDeNetaKbIANkxCK7Lqh2oiIka4R6Oic7iDdgDloD6ri3NC9I6GbWHgH9DH/hCp62VQr1NHw2F5G/RFsBFJFZRuCQRSQMCVIpIAFJIpIAakilSAMakqU2RAsUrOQwBPARDVI1iBjQ1PDVIGJwYlY6GAI5VIGIlqAGAJ1JJJDOQx2BiacQ0RR2M+SmNFW1xFaafCqGL7N82IDWtaH4OCZuVoa1ry2EkgcAQ923Gl0HSzKm12kaP8p+TnLHwmBLoZcSa+zwrsN454pCSPA5Gxj1Wnpp3Hkx9XCslJG7/JJLXSGFpoNuc0mr3jdr816X/LXi+z6PyAC5ZmgbA6AnT5Lx/+TPH9ljsI4nTt4WEcPtC5pN+Frtv5fOlwZcLhQf1bHTPHi4ih7NPurV8FJ/MjgugGZpHnm8gehAC7xcf1Qh+A/wBY+e67BZGod5Gb+lVYl9xIpJLgWBJIpIACSKSABSCKSAAkkUkwKuRBzFPlQc1RsVFUBWI2qKtVZjCbYkODUcqeAnUo2SI8qY8KchRyBNCK6SJQUhGV1gitjZPwHvfunQ/Vch03iC2KSHhJO3FA8M2R0Tx738l2nWCTLhpzddw0fEkAfVeeYjpASsyPbTm3keNQb3aR40PbxV/Rp02ZfiElwvMi6Mf9q2jRzBwN1XJaHWXFvnxBc55eXBrcxcXHYCrKrYPo68j+2gbsTmlAo8qCDe6/tHEPIJ0FgE875K8mn0Z21pcnf9WsNlbm8KHy/ID3W0qPQbicPC47uZmNaDUkq8sOd7nZ6THW1V6IIRQCKiTEkkkgBJJIoACBRSQAEEUEwAg5FNcoAV+KtxqkTqrsalIiiUJyATlAmgFRSoYvFRxNL5XtjaPvPcGj/Urk+kevEeogic/8L3nI0+Nb17LtjxTn8qOGXPjx/MzpSuf6X6zMha4xsMpDxGHbRl2tgO41lN+i5DpLpXET/rZCQ7/lttsYB/ZG/rafhcaDG2JsLpcrbI7KN4Dqq7dmAHm3nutDHo0uZsy83iLlxjVe5F0l09PidJHNDBdMYMrb58SfUrLpSusucTVlxugALvgBoPTRItGniQFcjFRVIzpzlJ3J2PhCnlV13Q9RDEZ48hkMQYJAZrDc2YsrRvC/LmoC0cRsp0QNboPpyeKmAh7NKY4XXlWvouvh6WbbWzAROdQALhudKI3bqK1HJcP0UH9qOyvPlcRlaXEDK7MaAJqr14b6Kz0vG8xutrQGMc05NWjvF2tE0bceXBV8ulhPy/cuYdZkx+d+x6EivLejenMRhjUchLB/yn2+P0H3fSl1/RvXCCShMDC7n8cZ9RqPUeqz8mkyQ65NTDr8U+Hw/f8AJ0aSZDMx4zMc17Ts5jg4e4T1VLqdiSQRQMCRSQKAEgigmAy0HFC0CVARUce96q/EVmSHveqvGZrGl73BrWi3OJoADipSXRFPssyzNY1z3uDWtFuc40AOZK4/pfr0NWYRmY7dtICG+bWbn1ryKw+s/WJ2LdkjtuHadBsZSPvO8OQ/PbHYygXey0dPo1W7J9jJ1XiDb24uvUfiMRJM8vle6R5+8436DkPAJmXYczSTRWTz+qljHfPgb/JaKVcGW227YzEuojkPyVqOEwxPc4AvdJE1rN+zdlkNv8ao5d7q6qjRndmd4A17la8YdioQ1wPa9sQ2QRkh5axoAkcNvjrNXK+ahNkoGQ4k6nUkkk+JNpVqP3m/UKzJgphmzwytLLzExvy0LJN1VaE34E81XI+o+qkmRZouOh8iof4kqchQFSEWcNebTcURW/3lt9ITOdhXl5c9w/SGhzi5zgBEw5bOlabXpaxcGe96N/8AZbGM/wDyybX/ADjlesI9eBT8gOYc23V4I5U4DvNPMBGVveA5pATYOR8Zzxvcx3NpIvz5jzXU9F9bDo3Et/7rB/iaPqPZcyEqXPJghkXxI7YdRkxP4X+D0+GZrwHMcHNOzmkEFPXmGFxkkLi6J7mHjR0d5jY+q6Xo7reDTcQzL/SR2W+rdx6Ws3Lopx5jyjYw+I458T4f/DqkkGPBAI1BAIPMHZJUy+IoIoIGVc6ReskYx3JI413JH6bOe9Esz+8szry28O09rkp4+y4TfnY35fJSYjE1meQe6C6hqdBei4/pHpB+Ik7R+w0Yy9GDkPzKuabC5TUvQoazPGMHHzZVayqViYU0BMjbZCfOdVqmIQzGsnmE7PQLuLnGlHijq1On0a30P1QAMHFnkYwmszgCRuBxWlHgWhoPaiPM1rw12Ow7HU4NIJaG6WHNOvI8tM/o51SA/hZK72Y4/kr/AEthny4p8cbXPdUTALsnLCwXZceXP+CQ0Xo8gAa5+HlMd9k9+PhJb8dA92ngZbAcDRc3gS1ZeMwwbWV8TwdhHMyYt2NOLfPkNQQtR3Qoia5tsdLXxkZmtNcOSycFBU8cbjmDpY2Oo6kOcA4bHWjyPkVGDT6OmSEopWafbQ9jk7I9v2uYT9oa7PLWTJt8WtrOU0jMjiNcpc8MJ1vK5zfe2ndQBdDkXejHAPOZnaNrVtPPB+vdcDpvv77LYxeMidG6NjezbUri0ve+y6JzQAC3TfclYeBxDo3Z2GnAijV8DoQdxqtfGkywCRudwbK8va55kLBkbeWyXFgsmydM2vMxcqZJK0YNaMP7I+ike3vNKUY7rfKvZSsGgUyIwHVPCiJ1UrCmBDPpSVWjieCdhYnPc1jdXPcGjzJpJ+4JWegdXcQ6TDxFwohuS/xBndDvWlpKLDQCNjI27MaGj0FWpF56bTk2j1eOLjBJ90IpJJKJMzP0VvJI4VvJTpFRtkKRj4qIB1cFwRiyucz8DnNP9U1+S9Bx3xLkencPknkHB9SDycNfnmWnopc17GV4jDhS9/8AfwU4humSHVSAUoZTqtEyStObI81LiTw8vooTq8KbFJADA7yHlDP843BdZ0XPGzpLECV2XP2kTHuJytdbau2ggHLV0PJct0WwuMjRVuika0EgWS00LK2sVhI5XvkMeLBkcXEN/RSBZNgAO8vmoTjui0SjLa7Ow6ZwTQ17ntawht9qfgAB3saHXRcJhXCTEwlgIBmgA0JJ77daGvoNVYlwIIaHDpAtFZQYWStacvD7Shr8k/B4Fsb43kYshj4nFpwR71G3D9Z4V4qGLG4LlnTJl38UTMaJskLiWm8Q+MjRuYyy2HAmh8I13FUdNsp8TmuLXgtc3Qgq+2bsnROexwPZyWw3G4ZpJRXhurLJIJgxkjHtLA4RyGZpJ/DG53Z/DsATdeR06cp+xz7RksFX6fRbWY4eBhI+27V/ZjMLhuNnec0a56OgO12eSDWw4ctfJDLnJOSF0rHaAkdo7ucD8I1BIs6aGHE4lj2NY0SWJJJXOkeHkl7GA7AcWH3G9JP4voPozovh8i76lSRFQ4d1h3g549ipISupAjO6lYoX7nzTmOQA+QWtvqVgs0rpSNIhTf3nWPkL9wsVxXe9X8F2MDGkU932j+du4egoeiq6zJsx15vgu6DFvy2+lz+DSSSSWMehEkkkgCmkUEioETMx3xLJ62Ybuwyjxjd6jM36O91q434lH1gLRhHl3Ds6887QPqreCW2cX/uSpqYKWOafpf2OLJVeY6qZzlWmK2TzxDHq9T4lQYf4lNiUgI8OPi9PqVqswUQGZ3aBojY9zhkIJc0HK0VqdT7ctVQ6NhzkgnK0NzvdvTWkkkDifD/6ugwnR7sbPh8PGSyPsWOGYh3ZsDbc6+Jqh51wUX3RJdWRYQCYOa2OV0LGjMwRxhsXHPnLtHfGS47jTbau/ANAOWRzvs3SNORuR+UEkZg80dOVr0mfoaCKJ2Fa1wjLNSHZXP5ku45iDfAjTZcNLB2E0sID3RmKR2Qn4qjdZa4A8iM1cxwQ1XQ7vsOFc0RZ3OIDI4jlY2Mudnle0m3A66IDFwHX7b1jwjvv+Lde58/BCZgEDwwucww4ctJDmmu3kqwDQOta3fDmVgeiz2YmeQGkWzezRIJPIaHz0TcklbCMHJ0hzsRE7vPMtkAE/omEOxAFai+4PehtqrAijID2EuBk7PK/D4ZmhZK6+64u2a3UCrvXZUMUy+94DTgP9/mr2E/VDmMRFyvWGfhVn3rw4hxdqwnHa6OewB0d++9SxHVQYA/rB/SFSsOqmiApdygCjMNVGCkBKZCNt+C9Pws4kYyQbPY149Ra8rdw8V33VDEZ8M1t2YnOYfK8zfk4D0VHXxuCl6f2afhk6m4+q/g20kEllG2JJBK0wKIKJKiDkcyiRM/GHvLL664jLh4owdZJAT4hgv6lq0cW7vLmOuU+aWNnCOIH1cdfkGq5po3OPsUNXPbil78Gcx1gHwVeYp+GdoRyKjxC1zCG4Xcp+KKZheKOJKQEmEkLCHNJa4BpBHDVdf1e6TjgxMM9WTABLE1td06l0Y+9WUW3etRdUuUwsWZ1W1tR2S68oAsnYE8OS0YZJW0G4mMVQFCWx/40mvQaZ6rien8A5hJxsGRzdMrw6Uf1ACb4VXtWnnuLxwnl7YxtYzspWQQubmdIwNdZeRuNXajY2BxKhdimmnulgLgBcVARuOwJLhbRW4HHbwpunlcSS/DEkFtg4UOAoigdxoa9kO2S4RaEpfA97u84wsJdluv5zVXfdGtVXLZdN1flZNAxsZb2sbckkRoFwB0cL30Oq5yBrWxsZJkc18Rack+Ha4ViM2jnXXwkIR4WA0Kl32GIwknA7bca9LUcuPeqToePI4OzR6xQNic0U0PcCDE3LY4ZnAHQ+CiwAIjdpYGJwn46BLZgNjl48RfKtVB/w6Np1GJbQ27KB33dNpB97Ty8dFZiY1tNYHuJmw0hdJHCzIGXn72ckauHDUDWqUoR2xqwyTcnZzGEPek/eBUhPeUOFPfk9FLIdQpnMfiNwq076HidAp8TsCqErrcEMC5Js3yXS9SMTUskR2kYHDzYf4O+S5uXYK50HiOzngfyeAfJ3dPyK5Z4bsbR2089mWMvc9LSQStYJ6gRQSJQtAGOHp2dZbccE/8ATQp7GcN6Bin95cb01Nnnld+1lH9UBv5LpsRiBZdwAv2XGucSbO5NnzK0dJGrZl6+fSHwmj56JsxTmDRMmV0zB2GQn3ToNkx2rh5oA0uj2gyOB/Awb1u9oOvDQ7qxjekZ+1lqeYASyZamf3RncRVHhZUPR36x+tU2M3dVUjdb4LV6KwbZJ8Q5wDuzkkI4izIRfI8ffbkpS2qyUY7nRVixmIY3OZ5tKppe540FCwbFUTol0dj5XSxMc+2mSJpDmxnQOA1JaeZ39bWp0jhHDM+wW6fsu1r5/wAVkYFh/SIuNyxHYn7w4N19tVGE9x1y49vRYiiDnxsLc3cmoUTffmIAA8QpI5sjmsjhjdO4kERmTuWPhHeNPFE393XiDU0EdZHBpcSJ2F1WIhmmOg3zE3RO1HfWuu6k9CRx4Zs2Rpmma7Vx0DM9NaOV1fqE+2c+kcxjsNHD2cU4abt4DJHOMN+JF0TwF3V6VRzMfA1gjIYWOL3g98PY4NawhzTWxzLtesmDzsILA6QMcW5m2eZpw1qmigOXLVcZFT2MjcNC6Y9oPiiGVne3+HmK8tdCNVyC54MbDH7R/qp5t1WhP2rvG/orMymQFiT3PZUGbq9Nqw+SoxnVDAvv+FCEWET8KGH2TA9Rws2djH/jY13uAVKsnqzNmw0X7Icz+y4gfKlqWvP5I7ZNe56rFLdBS9Ug2haCVqB0PPBKnCRVgU4FaNGWmSz25rmjcgjXbVYuIwcjNSLHEg2AthpUlAgg6g6Ec1KGRwOWXCsnL7MCNQylXsbCI3Na2yHMDtTsbIr5KhJ9QCrqaaMyUWnTJY9kGauCI2Sw/wASZE0ujhcr9a7rRd5at7Bvw33VlvSLocTNIyjc01tJBDgZDp/rX8FSwU2V8hIJsAaOyOBBa4EGjR7oWh/xiT8WJ4f9W/gS7g3mShpNUxptO0XMZ1ljc2mQ5XEEW6S2M8QKsnU7kLM6M700IJvNLHdjNduHCxflamHTUmnexGlf9Rm2sj4mHiSnR9LOFUZBVVrh3bGwdY9db33SjBR6JSm5dkuHkIkirYtnzDg5vaynKauxoOe3quq6u9OnDwiKXDYh0AJyhjLlhsklhuszLunb8NNFwk0wOUNa4BrcostJPec6+H4k7B4gxuzAHXRw0pwO4Ou38ENPtCT8mdh1g6wOxFRYaKaIuBD5ZmtY8t5AgnKOZvguXxso7JjGElvaODjpTzTDy0bpz1q+VCXpEgBsPaRtsE94l9jYAjZo086s8AKs+Ic+sz3urUBxc6udewRy+wtIpMP23t9ArUqpvNSj0+iuTKREcNWkcwVmsOq0Yjos9jbcQOBP1QwNBh7von4OB7x3I3v/AHGOf9Aj0dDnmZA6xnIBcNwDyXpOHiEbGsb8LGho8gKVbUalYqSVsu6XRvNbbpIyOqUUjIntkY5n2hLQ8EEgtHDzBW5aCCyck98nL1N3Fj/TgoryDaFoEpuZQOh5wE4JgTgtIyUStT2qNqe1RZNGf0wO9Ef2SP771lSb+y2ulo7EZsd0ybnfVhr+8saT4lcx9IzM6+Jk3BHCDvFMcpcCN11K5NBu/wA1MAocNu7zKnBTAgJT2OTZQo2lAFkJ9KJqkBQAiECnFMcmBTxX6weiuSFU8b8YPgFacdB5BIB0RVaEfauHMOrYakafNTwlQPIbK0nz/wB+yTGjquqPRvavfM4uc6JsbgfugXWvt8l2Cr9RImt6PxTmspzpg179y/KG16a/Mqa1l65/Gvob/h6rF+4bQtC0FSLwSgkhaAPOAnhMCeFpGSh7VIFG1SNUWTRU6XHcafwy1/aaP8ixbs+q7BuCjkicXtsh4rvObsPA+JXLYqMNkc1ooBxACuYvlRm6n52MerGCGhVZ6t4TZdUVhYXj5lWFXwnHzP1VgpgRyqFTyqu5AE7SpGqCNStQBKVG5PKY5AFXHjVp8FPfdHkocds1SM+EIAdCVBjtwf8Aeh/1U0Sbi3EVRrX8ikxo7/qR01F+izYTvCQzds3uuLS17Wmsw0BBbWvNaq5GDpGYwdHsMry39MkbROpH810veu873K61ZWtXxpm74fJvG16MKBKCBVM0BEoWkU20Af/Z",
        ),
        CarouselItemWidget(
          title: "Buba & Sokoto",
          imageUrl: "https://via.placeholder.com/300x200.png?text=Buba+%26+Sokoto",
        ),
        CarouselItemWidget(
          title: "Kaftan",
          imageUrl: "https://via.placeholder.com/300x200.png?text=Kaftan",
        ),
        CarouselItemWidget(
          title: "Wrapper & Blouse",
          imageUrl: "https://via.placeholder.com/300x200.png?text=Wrapper+%26+Blouse",
        ),
        CarouselItemWidget(
          title: "Senator",
          imageUrl: "https://via.placeholder.com/300x200.png?text=Senator",
        ),
  ],
),



            const SizedBox(height: 30),

  CategorySlider(
  categories: const [
    {"title": "Shirts", "imageUrl": "https://i.pravatar.cc/150?img=10"},
    {"title": "Jeans", "imageUrl": "https://i.pravatar.cc/150?img=20"},
    {"title": "Shoes", "imageUrl": "https://i.pravatar.cc/150?img=30"},
    {"title": "Hats", "imageUrl": "https://i.pravatar.cc/150?img=40"},
    {"title": "Jackets", "imageUrl": "https://i.pravatar.cc/150?img=50"},
  ],
  onCategoryTap: (index) {
    print("Tapped category $index");
  },
),



            ],
          ),
        ),
      ),
    );
  }
}

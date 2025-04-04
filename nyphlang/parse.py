from PIL import Image
from json import dump

# nyph = Image.open("nyphlang_map.png")
# map = nyph.load()

def print_pattern(pattern: Image):
    map = pattern.load()
    switch = lambda x, y : "⬛" if map[x,y][1]!=0 else "⬜"
    print(
         switch(0,0)+switch(1,0)+switch(2,0)+switch(3,0)+switch(4,0)+"\n"
        +switch(0,1)+switch(1,1)+switch(2,1)+switch(3,1)+switch(4,1)+"\n"
        +switch(0,2)+switch(1,2)+switch(2,2)+switch(3,2)+switch(4,2)+"\n"
        +switch(0,3)+switch(1,3)+switch(2,3)+switch(3,3)+switch(4,3)+"\n"
        +switch(0,4)+switch(1,4)+switch(2,4)+switch(3,4)+switch(4,4)
    )

def get_labels():
    labels = []
    a = "kbhjfhk"
    print("labels:")
    while a != "":
        a = input("")
        if a != "": labels.append(a)
    return labels

def scrunge_crop(crop: Image):
    map = crop.load()
    switch = lambda x, y : 0 if map[x, y][1] == 0 else 1
    wenis = [switch(x, y) for y in range(5) for x in range(5)]
    wenis = [x << i for i, x in enumerate(wenis)]
    return sum(wenis)

def get_join_flags(crop: Image):
    map = crop.load()
    switch = lambda x, y : 0 if map[x, y][1] == 0 else 1
    top = sum([x << j for j, x in enumerate([switch(i, 0) for i in range(5)])])
    bottom = sum([x << j for j, x in enumerate([switch(i, 4) for i in range(5)])])
    return top, bottom

data = {
    "labels": {},
    "patterns": {}
}

# crop = nyph.crop((0,0,5,5))
# print_pattern(crop)

# for y in range(nyph.height//5):
#     for x in range(nyph.width//5):
#         crop = nyph.crop((x*5, y*5, x*5+5, y*5+5))
#         if len(crop.getcolors()) == 1: continue
#         print(x*5, y*5)
#         print_pattern(crop)
#         scrunge = scrunge_crop(crop)
#         for x in get_labels():
#             data["labels"][x] = scrunge
#         top, bottom = get_join_flags(crop)
#         data["patterns"][scrunge] = {
#             "top": top,
#             "bottom": bottom
#         }

# with open("data.json", "wt") as fp:
#     dump(data, fp, indent=2)

# x, y = 3, 9
# crop = nyph.crop((x*5, y*5, x*5+5, y*5+5))
# print(scrunge_crop(crop))
# print(get_join_flags(crop))


# for i in range(32):
#     print("{0:b}".format(i), i&i>>1&i>>2!=0)
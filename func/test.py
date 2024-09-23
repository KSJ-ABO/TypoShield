import sys
import algo

package = sys.argv[1]

list=algo.main(package)

cnt = len(list)

if cnt > 0:
    array =list[0]
    name =array[0]
    accuracy=array[1]
    if cnt == 3:
        array2 =list[1]
        name2 =array2[0]
        accuracy2=array2[1]
        
        array3 =list[2]
        name3 = array3[0]
        accuracy3 = array3[1]
    elif cnt == 2:
        array2 =list[1]
        name2 =array2[0]
        accuracy2=array2[1]

        name3 = ""
        accuracy3 = 0
    else:
        name2 =""
        accuracy2=0
        
        name3 = ""
        accuracy3 = 0
    if accuracy == 1:
        print("%2lf %s %d" % (accuracy, name, 0))
    elif accuracy > 0.9 :
        print("%2lf %s %d %2lf %s %2lf %s" % (accuracy, name, 1, accuracy2, name2, accuracy3, name3))
    else:
        print("%2lf %s %d %2lf %s %2lf %s" % (accuracy, name, 2, accuracy2, name2, accuracy3, name3))
else:
    print("%2lf %s %d" %(0,"",0))

import sys
import algo

package = sys.argv[1]

list=algo.main(package)


cnt = len(list)
array =list[0]
name =array[0]
accuracy=array[1]

if accuracy == 1:
    print("%2lf %s %d" % (accuracy, name, 0))
elif accuracy > 0.9 :
    print("%2lf %s %d" % (accuracy, name, 1))
else:
    print("%2lf %s %d" % (accuracy, name, 2))

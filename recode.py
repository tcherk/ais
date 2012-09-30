import sys
i=file(sys.argv[1])
o=file(sys.argv[2], 'w')

i=i.read()
t=unicode(i, 'cp1251')
t=t.encode('koi8-r', 'ignore')
o.write(t)
o.close()
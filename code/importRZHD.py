import sqlite3 as sql
import csv

# Соединение с базой данных. БД будем создавать заново.
try:
    conn=sql.connect('rzd.db')
except sql.OperationalError:
    print ("DB is locked. Terminating.")
    quit()

def cities():
    c=conn.cursor()
    c.execute("""DROP TABLE IF EXISTS city""")
    c.execute("""
              CREATE TABLE IF NOT EXISTS city (
              name text,
              lon real,
              lat real,
              state text
              )
              """)
    c.execute("""DELETE FROM city""")

    # Формат файла - колонки, разделенные символами табуляции.
    with open('city_coords.txt', 'r') as csvfile:
        reader = csv.reader(csvfile, delimiter='\t')
        u=conn.cursor()
        rows=[]
        for row in reader:
            row=[c.strip() for c in row]
            row=[row[0],float(row[1]),float(row[2]),row[3]]
            rows.append(row)
            # print (row)
        # Добавить одним залпом данные для всей таблицы.
        u.executemany("INSERT INTO city (name, lon, lat, state) VALUES (?,?,?,?)", rows)

CNTERR=40
def printwarn(*args):
    global CNTERR
    print ("???>", *args)
    CNTERR-=1
    if CNTERR<=0:
        raise SystemExit(1)

state=0

REPLACES={
    "бывш.":"бывший",
    "Пут.":"Путевой",
    }

def appreplace(s):
    b=None
    while True:
        p=s
        for k,v in REPLACES.items():
            b=s.replace(k,v)
            s=b
        if p==s:
            break

    return p

def proc(a, complex=False):
    try:
        a=a.strip()
    except AttributeError:
        return a
    a=a.strip('\xa0')
    a=a.split('\xa0')[0]
    try:
        return int(a)
    except ValueError:
        pass
    try:
        return float(a)
    except ValueError:
        pass
    if '.' in a:
        a=appreplace(a)
        # if '.' in a:
        #     print (".", a)
    return a

def nameproc(a):
    #if not complex:
    #    return a
    if '-' in a:
        la=a.split('-')
        # try:
        #     int(la[-1])
        #     a='-'.join(la[:-1])+":"+la[-1]
        # except ValueError:
        #     pass
        # la=a.split('-')
        #if len(la)>2 and la[-1] and la[-1][0].islower():
        #    a=la[0]+'-'+''.join(la[1:])
        ln=[la[0]]
        for lt in la[1:]:
            if lt:
                if lt[0].isupper() or lt[0].isnumeric():
                    ln.append('-'+lt)
                else:
                    ln.append(lt)
        a=''.join(ln)
        #print ("-",a)
        a=a.replace('а-Тов.-','а-Товарная-')
    return a

def pproc(l, complex=False):
    return [proc(a,complex) for a in l]

def listjoin(l):
    b,e=l[0],l[1:]
    for r in e:
        for i,c in enumerate(r):
            _=' '
            if type(b[i])==type(''):
                if b[i].endswith('-'):
                    _=''
                b[i]=proc(str(b[i])+_+str(c))
            else:
                if str(c).strip():
                    printwarn ('---', c, b[i],l)
                    print(b)
    return b

def update_st(l, col):
    name=l[0]
    name=nameproc(name)
    l[0]=name
    stations=l[col]
    sts=stations.split(',')
    citysts=[]
    for st_ in sts:
        sd=st_.split('-')
        try:
            dist=int(sd[-1])
            st='-'.join(sd[:-1])
        except ValueError:
            dist=0
            st=st_
        st=nameproc(st.strip())
        citysts.append((st, dist))
    l[col]=citysts

REGIONS={}
STATIONS={}
ROUTES={}

def findroute(rou, region):
    try:
        return STATIONS[(rou,region)][0]
    except KeyError:
        if rou.endswith('.'):
            rou=rou.strip('.')
        for k,v in STATIONS.items():
            if type(k)==type(''):
                if k.startswith(rou):
                    sk=k
                    try:
                        e=STATIONS[(k,region)][0]
                        # print ("Found:", rou, 'as', k)
                        return e
                    except KeyError:
                        e=None
                        for k,v in STATIONS.items():
                            if type(k)==type((0,0)):
                                if k[0]==sk:
                                    e=v[0]
                                    # print ("Found hard:", rou, 'as', e)
                                    return e
    return None


def rzhd():
    global REGIONS, STATIONS, ROUTES
    def senseline(f):
        while 1:
            s=f.readline()
            if len(s)==0:
                break
            ss=s
            if len(ss)==0:
                continue
            if s[0] in ['│', '\xa0']:
                ss='\xa0'+ss[1:]
                ss=ss.split('│')
                if ss[0].strip().startswith('- участников'):
                    continue
                if ' ' in ss[0][20:-1] or not ss[0][:20].replace('\xa0',' ').strip():
                    ss[0]=ss[0][:21]
                ss=pproc(ss)
                yield 1,ss
                continue
            if ss.startswith('┌'):
                yield 3,None
                continue
            if ss.startswith('└'):
                yield 4,None
                continue
            if ss.startswith('├'):
                yield 4,None
                continue
            if ss.startswith('*****'):
                yield 5,None
                continue
            yield 0,ss

    def sensedata(f, rcol): # rcol - the number of the colum to handle data starts
        global state
        acc=[]
        for _ in senseline(f):
            if state==0:
                if acc:
                    yield listjoin(acc)
                acc=[]
            t,d=_
            if t==5:
                return
            if t==0:
                if state==0:
                    continue
                if type(d)==type(''):
                    continue
                if len(d)<=1:
                    continue
                printwarn("BAD",d)
            if t==1:
                if len(d)<=4:
                    continue
#            printwarn(state,t,d)
            if t==4:
                state=4 # start parsing data
                continue
            if t==3:
                state=0 # start parsing header (not data at all)
                continue
            if t==1 and state==0:
                continue
            if t==1 and d[:2]==[1,2]: # parsing subheader
                state=0
                continue
            if t==1 and state in [4,5]: # parsing data
                try:
                    if not ''.join(d):
                        continue
                except TypeError:
                    pass
                # print ("<<<",d)

                drcols=str(d[rcol])
                try:
                    while drcols:
                        if state==5:
                            state=4
                            break
                        if drcols.endswith('-'):
                            state=5
                        if acc:
                            yield listjoin(acc)
                            acc=[]
                        break
                    acc.append(d)
                    continue
                except IndexError:
                    continue
            yield t,d



    tar_ruc=open("tar_ruc.txt")


    u=conn.cursor()
    u.execute("""DROP TABLE IF EXISTS region""")
    u.execute("""
              CREATE TABLE IF NOT EXISTS region (
              name text,
              abbr text
              )
              """)
    u.execute("""DELETE FROM region""")

    u.execute("""DROP TABLE IF EXISTS station""")
    u.execute("""
              CREATE TABLE IF NOT EXISTS station (
              name text,
              region int REFERENCES region (OID),
              code int,
              transit int
              )
              """)
    u.execute("""DELETE FROM station""")

    u.execute("""DROP TABLE IF EXISTS dist""")
    u.execute("""
              CREATE TABLE IF NOT EXISTS dist (
              a int REFERENCES station (OID),
              b int REFERENCES station (OID),
              dist int
              )
              """)
    u.execute("""DELETE FROM dist""")

    for l in sensedata(tar_ruc,5):
        #l=pproc(l, complex=True)
        st_num=l[-1]
        if not st_num:
            continue
        try:
            st_num=int(st_num)
        except ValueError:
            continue
        except TypeError:
            continue
        l[0]=l[0].split('\xa0')[0]
        update_st(l,4)
        l=pproc(l,complex=True)
        # print (l)
        name, region, _,_, routes, code=l
        # print (name, region, routes, code)

        REGIONS.setdefault(region, None)
        STATIONS.setdefault((name, region), [code])
        STATIONS.setdefault(name, []).append(region)
        STATIONS.setdefault(code, [name, region])
        ROUTES.setdefault(code, []).extend(routes)

    print("Rote db imported.")
    print ("Regions:", len(REGIONS))
    print ("Stations:", len(STATIONS))
    print ("Routes:", len(ROUTES))

    u=conn.cursor()
    for k,v in REGIONS.items():
        u.execute("INSERT INTO region (abbr) values (?)", (k,))
        REGIONS[k]=u.lastrowid

    for code in ROUTES.keys():
        name,region=STATIONS[code]
        if name.endswith('.'):
            printwarn('...', name)
        tp=False
        rs = ROUTES[code][0][0]
        if rs=='ТП':
            tp=True
        u.execute("INSERT INTO station (name, region, code, transit) values (?,?,?,?)",
                  (name,region,code,tp))
        rowid=u.lastrowid
        STATIONS[(name,region)].append(rowid)
        STATIONS[code].append(rowid)

    for code in ROUTES.keys():
        name,myregion,rowid=STATIONS[code]
        rs=ROUTES[code]
        if rs[0][0]=='ТП':
            continue
        # printwarn (code, name, region, rs)
        for rou,dist in rs:
            if not rou:
                continue
            regions = STATIONS[name]
            if len(regions)>1:
                #printwarn ("MUL:",rou,regions)
                if not myregion in regions:
                    print ("No station in the same region.")
                else:
                    region=myregion
            else:
                region=regions[0]
            s=code
            #printwarn(name,rou,dist, myregion, regions)
            e=findroute(rou, region)
            if e==None:
                print ("Lost in space:", rou)
                #print (STATIONS.keys())

                continue

            u.execute("INSERT INTO dist (a,b,dist) values (?,?,?)",
                      (s,e,dist))

    u=conn.cursor()
    u.execute("""DROP TABLE IF EXISTS cityst""")
    u.execute("""
              CREATE TABLE IF NOT EXISTS cityst (
              city text,
              station int REFERENCES station (OID),
              dist int
              )
              """)
    u.execute("""DELETE FROM cityst""")

    #u.execute("BEGIN")

    for l in sensedata(tar_ruc,3):
        l=pproc(l[:4], complex=True)
        station=l[2]
        update_st(l,2)
        city, _, stations, road = l
        city=nameproc(city)
        for st,dist in stations:
            st=nameproc(st)
            e=findroute(st, road)
            if e==None:
                print ("Cannot associate %s with station %s" % (city,st))
                continue
            u.execute("INSERT INTO cityst (city,station,dist) values (?,?,?)",
                      (city, e, dist))
        #printwarn(city, stations)
    print ("City-station data imported.")
    #u.execute("COMMIT")
    u.execute("""DROP TABLE IF EXISTS route""")
    del u




if __name__=="__main__":
    print ()
    cities()
    rzhd()
    conn.close()
    del conn
    quit()

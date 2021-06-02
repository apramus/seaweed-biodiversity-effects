
# these tests the null that the net biodiversity and its component selection and complementarity effects do not differ from 0 (negative values are interpreted as "no effect")
# needs annotation

nm.ce<-c(16.8066762, 21.58020161, 45.71896223, 37.65772318, -2.641622259)
nm.ces<-abs(nm.ce)^.5
t.test (nm.ce)
t.test (nm.ces)

inv.ce<-c(21.34212212, 34.1736598, 15.13726259, 11.82832006, 77.74504573)
inv.ces<-abs(inv.ce)^.5
t.test (inv.ce)
t.test (inv.ces)

poly.ce<-c(17.23599777, -8.632652559, 25.72577061, 67.86328433, 1.962682188)
poly.ces<-abs(poly.ce)^.5
t.test (poly.ce)
t.test (poly.ces)

nm.de<-c(15.2149857, 34.67969758, -50.65344334, 2.188415229,16.51243339)
nm.des<-abs(nm.de)^.5
t.test (nm.de)
t.test (nm.des)

inv.de<-c(31.57848348, 4.918823037, 33.76077278, 8.724186575, -24.15090193)
inv.des<-abs(inv.de)^.5
t.test (inv.de)
t.test (inv.des)

poly.de<-c(16.21866964, 4.376870079, 30.23230586, -11.72882356, 7.805312638)
poly.des<-abs(poly.de)^.5
t.test (poly.de)
t.test (poly.des)

nm.be<-c(32.0216619, 56.25989919, -4.934481114, 39.84613841, 13.87081113)
nm.bes<-abs(nm.be)^.5
t.test (nm.be)
t.test (nm.bes)

inv.be<-c(52.9206056, 29.25483677, 48.89803537, 20.55250664, 53.5941438)
inv.bes<-abs(inv.be)^.5
t.test (inv.be)
t.test (inv.bes)

poly.be<-c(33.45466741, -4.25578248, 55.95807646, 56.13446078, 9.767994826)
poly.bes<-abs(poly.be)^.5
t.test (poly.be)
t.test (poly.bes)

# update? 02 Jun 21 below

nm.ce<-c(16.8066762, 21.58020161, 45.71896223, 37.65772318, -2.641622259)
nm.ces<-abs(nm.ce)^.5*abs(nm.ce)/nm.ce
t.test (nm.ce)
t.test (nm.ces)
 
inv.ce<-c(21.34212212, 34.1736598, 15.13726259, 11.82832006, 77.74504573)
inv.ces<-abs(inv.ce)^.5*abs(inv.ce)/inv.ce
t.test (inv.ce)
t.test (inv.ces)
 
poly.ce<-c(17.23599777, -8.632652559, 25.72577061, 67.86328433, 1.962682188)
poly.ces<-abs(poly.ce)^.5*abs(poly.ce)*poly.ce
t.test (poly.ce)
t.test (poly.ces)
 
nm.de<-c(15.2149857, 34.67969758, -50.65344334, 2.188415229,16.51243339)
nm.des<-abs(nm.de)^.5*abs(nm.de)/nm.de
t.test (nm.de)
t.test (nm.des)
 
inv.de<-c(31.57848348, 4.918823037, 33.76077278, 8.724186575, -24.15090193)
inv.des<-abs(inv.de)^.5*abs(inv.de)/inv.de
t.test (inv.de)
t.test (inv.des)
 
poly.de<-c(16.21866964, 4.376870079, 30.23230586, -11.72882356, 7.805312638)
poly.des<-abs(poly.de)^.5*abs(poly.de)*poly.de
t.test (poly.de)
t.test (poly.des)
 
nm.be<-c(32.0216619, 56.25989919, -4.934481114, 39.84613841, 13.87081113)
nm.bes<-abs(nm.be)^.5*abs(nm.be)/nm.be
t.test (nm.be)
t.test (nm.bes)
 
inv.be<-c(52.9206056, 29.25483677, 48.89803537, 20.55250664, 53.5941438)
inv.bes<-abs(inv.be)^.5*abs(inv.be)/inv.be
t.test (inv.be)
t.test (inv.bes)
 
poly.be<-c(33.45466741, -4.25578248, 55.95807646, 56.13446078, 9.767994826)
poly.bes<-abs(poly.be)^.5*abs(poly.be)*poly.be
t.test (poly.be)
t.test (poly.bes)

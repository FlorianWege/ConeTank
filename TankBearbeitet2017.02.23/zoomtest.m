time=1:0.01:100;
val=101:0.01:200;


f=figure(1);
plot(time, val);
obj=datacursormode(f);
set(obj, 'DisplayStyle','datatip', 'SnapToDataVertex','off','Enable','on');

figure(3)
plot(nfo.xpos(:,1),nfo.ypos(:,1),'*b')
grid on
axis([-2 2 -1 1])
text(nfo.xpos,nfo.ypos,nfo.clab')
text(nfo.xpos,nfo.ypos,strcat('\newline',string(1:118)))

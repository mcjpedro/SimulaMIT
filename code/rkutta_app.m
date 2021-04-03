function [k] = rkutta_app(estado, momj, rr, rs)

     global we torquee torquec vds vqs vos ids iqs ios idr iqr ior
     
     fds = estado(1);
     fqs = estado(2);
     fdr = estado(4);
     fqr = estado(5);
     wr = estado(7);
                    
     k(1) = (vds - rs*ids + we*fqs);
     k(2) = (vqs - rs*iqs - we*fds);
     k(3) = (vos - rs*ios);
     k(4) = (- rr*idr + (we - wr)*fqr);
     k(5) = (- rr*iqr - (we - wr)*fdr);
     k(6) = (- rr*ior);
     k(7) = ((torquee - torquec)/momj);
 
 end
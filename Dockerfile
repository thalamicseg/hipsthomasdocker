# Generated by: Neurodocker version 0.7.0+0.gdc97516.dirty
# Latest release: Neurodocker version 0.7.0
# Timestamp: 2020/09/19 21:55:34 UTC
# 
# Thank you for using Neurodocker. If you discover any issues
# or ways to improve this software, please submit an issue or
# pull request on our GitHub repository:
# 
#     https://github.com/ReproNim/neurodocker

FROM thomas

ADD ./hipsthomas_csh /opt/thomas_new
ADD ./thomas_csh_mvcc /opt/thomas_new
ADD ./THOMAS.py /opt/thomas_new
ADD ./THOMAS_constants.py /opt/thomas_new
ADD ./origtemplate_mni.nii.gz /opt/thomas_new
ADD ./imgtools.py /opt/thomas_new/libraries
ADD ./ants_nonlinear.py /opt/thomas_new/libraries
ADD ./remap_image.py /opt/thomas_new/libraries
RUN chmod +x /opt/thomas_new/thomas* 
RUN chmod +x /opt/thomas_new/hips* 
RUN chmod +x /opt/thomas_new/*.py
RUN chmod +x /opt/thomas_new/libraries/*.py
ENV THOMAS_HOME="/opt/thomas_new"
ENV PATH="/opt/thomas_new:$PATH"

CMD ["/bin/bash"]

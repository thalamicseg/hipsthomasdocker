"""
Paths, names, optimized hyper-parameters, and other constants for THOMAS.
"""
import os
import shelve


image_name = 'WMnMPRAGE_bias_corr.nii.gz'
# Find path for priors
this_path = os.path.dirname(os.path.realpath(__file__))
orig_template = os.path.join(this_path, 'origtemplate.nii.gz')
assert os.path.exists(orig_template)
orig_template_mni = os.path.join(this_path, 'origtemplate_mni.nii.gz')
assert os.path.exists(orig_template_mni)
template_61 = os.path.join(this_path, 'templ_61x91x62.nii.gz')
assert os.path.exists(template_61)
template_93 = os.path.join(this_path, 'templ_93x187x68.nii.gz')
assert os.path.exists(template_93)
template_93b = os.path.join(this_path, 'p15_templ_93x187x68.nii.gz')
assert os.path.exists(template_93b)
mask_61 = os.path.join(this_path, 'mask_templ_61x91x62.nii.gz')
assert os.path.exists(mask_61)
mask_93 = os.path.join(this_path, 'mask_templ_93x187x68.nii.gz')
assert os.path.exists(mask_93)
mask_93b = os.path.join(this_path, 'mask_templ_93x187x68_p15.nii.gz')
assert os.path.exists(mask_93b)
prior_path = os.path.join(this_path, 'priors/')
assert os.path.exists(prior_path)
subjects = [el for el in os.listdir(prior_path) if os.path.isdir(os.path.join(prior_path, el)) and not el.startswith('.')]
assert len(subjects) > 0

# Names for command-line options and label filenmaes
roi = {
    'param_all': 'ALL',  # special keyword to select all the rois
    'param_names': ('thalamus', 'av', 'va', 'vla', 'vlp', 'vpl', 'vl', 'pul', 'lgn', 'mgn', 'cm', 'md', 'hb', 'mtt'),
    'label_names': ('1-THALAMUS', '2-AV', '4-VA', '5-VLa', '6-VLP', '7-VPL', '4567-VL', '8-Pul', '9-LGN', '10-MGN', '11-CM', '12-MD-Pf', '13-Hb', '14-MTT'),
    }
roi_choices = (roi['param_all'],)+roi['param_names']

# Optimized hyper-parameters for PICSL
#db = shelve.open(os.path.join(this_path, 'cv_optimal_picsl_parameters.shelve'), flag='r')
#optimal = dict(db)
#db.close()
optimal = dict()
optimal = {'PICSL': {'5-VLa': {'beta': 0.5, 'score': 0.61647925000000003, 'rp': [2.0, 2.0, 2.0], 'rs': [3.0, 3.0, 3.0]}, '2-AV': {'beta': 1.0, 'score': 0.75553215624999992, 'rp': [2.0, 2.0, 2.0], 'rs': [4.0, 4.0, 4.0]}, '14-MTT': {'beta': 1.0, 'score': 0.64393765624999999, 'rp': [2.0, 2.0, 2.0], 'rs': [1.0, 1.0, 1.0]}, '10-MGN': {'beta': 5.0, 'score': 0.63739243749999996, 'rp': [3.0, 3.0, 3.0], 'rs': [2.0, 2.0, 2.0]}, '7-VPL': {'beta': 0.5, 'score': 0.61675868749999996, 'rp': [5.0, 5.0, 5.0], 'rs': [2.0, 2.0, 2.0]}, '4567-VL': {'beta': 2.0, 'score': 0.80880984374999998, 'rp': [3.0, 3.0, 3.0], 'rs': [2.0, 2.0, 2.0]}, '4-VA': {'beta': 0.5, 'score': 0.64682046874999999, 'rp': [5.0, 5.0, 5.0], 'rs': [0.0, 0.0, 0.0]}, '6-VLP': {'beta': 1.0, 'score': 0.69648359375000002, 'rp': [5.0, 5.0, 5.0], 'rs': [2.0, 2.0, 2.0]}, '11-CM': {'beta': 0.10000000000000001, 'score': 0.65230337500000002, 'rp': [2.0, 2.0, 2.0], 'rs': [1.0, 1.0, 1.0]}, '1-THALAMUS': {'beta': 1.0, 'score': 0.90461968749999999, 'rp': [2.0, 2.0, 2.0], 'rs': [4.0, 4.0, 4.0]}, '12-MD-Pf': {'beta': 2.0, 'score': 0.81991278125, 'rp': [2.0, 2.0, 2.0], 'rs': [2.0, 2.0, 2.0]}, '8-Pul': {'beta': 0.5, 'score': 0.83126987500000005, 'rp': [2.0, 2.0, 2.0], 'rs': [3.0, 3.0, 3.0]}, '9-LGN': {'beta': 0.5, 'score': 0.66429712500000004, 'rp': [2.0, 2.0, 2.0], 'rs': [3.0, 3.0, 3.0]}, '13-Hb': {'beta': 0.5, 'score': 0.63729618750000006, 'rp': [1.0, 1.0, 1.0], 'rs': [5.0, 5.0, 5.0]}}}



if __name__ == '__main__':
    print(subjects)
    print(optimal)

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <assert.h>
#include <openssl/bio.h>
#include <openssl/err.h>
#include <openssl/pem.h>
#include <openssl/x509.h>

// forward declarations
int packit(char* crl_file, char* vrl_file, char* bundle_file);
int unpackit(char* bundle_file, char* crl_file, char* vrl_file);

int main (int argc, char **argv) {

  int unpack_flag = 0;
  char crl_file[256] = "";
  char vrl_file[256] = "";
  char bundle_file[256] = "";
  int c;

  while ((c = getopt (argc, argv, "c:v:b:r")) != -1) {
    switch (c) {
      case 'c':
        strlcpy(crl_file, optarg, sizeof(crl_file));
        break;
      case 'v':
        strlcpy(vrl_file, optarg, sizeof(vrl_file));
        break;
      case 'b':
        strlcpy(bundle_file, optarg, sizeof(bundle_file));
        break;
      case 'r':
        unpack_flag = 1;
        break;
      case '?':
        break;
      default:
        exit(1);
    }
  }

  if (!strlen(crl_file) || !strlen(vrl_file) || !strlen(bundle_file)) {
    printf("\n");
    printf("Usage: %s [-r] -c <crls.pem>> -v <vrl.pk7> -b <bundle.pk7>>\n", argv[0]);
    printf("\n");
    printf("  -r: reverses the packing operation...\n");
    printf("  -c: the PEM filename containing CRLs, or to be created (crls.pem)\n");
    printf("  -v: the PK7 filename containing a VRL, or to be created (vrl.pk7)\n");
    printf("  -b: the PK7 filename containing the bundle, or to be created (e.g., bundle.pk7)\n");
    printf("\n");
    exit(1);
  }


  if (unpack_flag == 0) {
    //printf ("packing %s + %s to %s...\n", crl_file, vrl_file, bundle_file);
    if (!packit(crl_file, vrl_file, bundle_file)) {
      printf("fatal error.\n");
      exit(1);
    }
  } else {
    //printf ("unpacking %s to %s + %s...\n", bundle_file, crl_file, vrl_file);
    if (!unpackit(bundle_file, crl_file, vrl_file)) {
      printf("fatal error.\n");
      exit(1);
    }
  }

  exit (0);
}



int packit(char* crl_file, char* vrl_file, char* bundle_file) {
  BIO* bio_err = NULL;
  BIO* crl_bio = NULL;
  BIO* vrl_bio = NULL;
  BIO* out_bio = NULL;
  STACK_OF(X509_INFO)* x509_info_stack = NULL;
  X509_INFO* x509_info;
  STACK_OF(X509_CRL)* crl_stack = NULL;
  X509_CRL* crl = NULL;
  PKCS7* p7 = NULL;
  int count = 0;
  int ret = -1;


  if ((bio_err = BIO_new(BIO_s_file())) == NULL) {
    printf("BIO_new(BIO_s_file()) failed\n");
    exit(1);
  }
  BIO_set_fp(bio_err, stderr, BIO_NOCLOSE | BIO_FP_TEXT);

  if ((crl_bio = BIO_new(BIO_s_file())) == NULL) {
    printf("BIO_new(BIO_s_file()) failed\n");
    return 0;
  }

  if ((out_bio = BIO_new(BIO_s_file())) == NULL) {
    printf("BIO_new(BIO_s_file()) failed\n");
    return 0;
  }

  if (BIO_read_filename(crl_bio, crl_file) <= 0) {
    printf("error opening the file, %s\n", crl_file);
    return 0;
  }

  x509_info_stack = PEM_X509_INFO_read_bio(crl_bio, NULL, NULL, NULL);
  if (x509_info_stack == NULL) {
    printf("PEM_X509_INFO_read_bio(crl_bio, NULL, NULL, NULL) failed\n");
    return 0;
  }

  crl_stack = sk_X509_CRL_new_null();
  if (crl_stack == NULL) {
    printf("sk_X509_CRL_new_null() failed\n");
    return 0;
  }

  count = sk_X509_INFO_num(x509_info_stack);
  //printf("info: there is %d entries in the PEM file...\n", count);

  char buf[256];
  //for (int i=count-1; i>=0; i--) {    // no matter which order the CRLs are added to stack, the
  for (int i=0; i<count; i++) {         // p7 always has the trust_anchor before the intermediate
    x509_info = sk_X509_INFO_value(x509_info_stack, i);   // - as confirmed in asn1parse...
    assert(x509_info->x509 == NULL);
    assert(x509_info->x_pkey == NULL);
    assert(x509_info->crl != NULL);
    sk_X509_CRL_push(crl_stack, x509_info->crl);
    //printf("storing CRL w/ issuer CN %s\n", X509_NAME_oneline(X509_CRL_get_issuer(x509_info->crl), buf, sizeof(buf)));
  }
/*
  count = sk_X509_CRL_num(crl_stack);
  printf("In just created crl_stack, found %d CRLs...\n", count);
  //for (int i=count-1; i>=0; i--) {
  for (int i=0; i<count; i++) {
    crl = sk_X509_CRL_value(crl_stack, i);
    printf("CRL %d issuer CN %s\n", i, X509_NAME_oneline(X509_CRL_get_issuer(crl), buf, sizeof(buf)));
  }
*/

  if ((vrl_bio = BIO_new(BIO_s_file())) == NULL) {
    printf("BIO_new(BIO_s_file()) failed\n");
    return 0;
  }

  if (BIO_read_filename(vrl_bio, vrl_file) <= 0) {
    printf("error opening the file, %s\n", vrl_file);
    goto end;
  }

  if (d2i_PKCS7_bio(vrl_bio, &p7) == 0) {
    BIO_printf(bio_err, "unable to read pkcs7 object\n");
    ERR_print_errors(bio_err);
    goto end;
  }

  assert(OBJ_obj2nid(p7->type) == NID_pkcs7_signed);
  assert(p7->d.sign != NULL);
  assert(OBJ_obj2nid(p7->d.sign->contents->type) == NID_pkcs7_data);
  assert(ASN1_INTEGER_get(p7->d.sign->version) == 1);

  p7->d.sign->crl = crl_stack;  // set the crl_stack

  if (BIO_write_filename(out_bio, bundle_file) <= 0) {
     perror(bundle_file);
     goto end;
  }

  if (i2d_PKCS7_bio(out_bio, p7) == 0) {
    BIO_printf(bio_err, "unable to write pkcs7 object\n");
    ERR_print_errors(bio_err);
    goto end;
  }

  ret = 1;

end:

  if (crl_bio != NULL)
    BIO_free(crl_bio);
  if (vrl_bio != NULL)
    BIO_free(vrl_bio);
  if (x509_info_stack != NULL)
    sk_X509_INFO_pop_free(x509_info_stack, X509_INFO_free);
  if (crl_stack != NULL)
    sk_X509_CRL_free(crl_stack);

  return ret;
}



int unpackit(char* bundle_file, char* crl_file, char* vrl_file) {
  BIO* bio_err = NULL;
  BIO* bundle_bio = NULL;
  BIO* vrl_bio = NULL;
  STACK_OF(X509_INFO)* x509_info_stack = NULL;
  X509_INFO* x509_info;
  STACK_OF(X509_CRL)* crl_stack = NULL;
  X509_CRL* crl = NULL;
  PKCS7* p7 = NULL;
  int count = 0;
  int ret = -1;

  if ((bio_err = BIO_new(BIO_s_file())) == NULL) {
    printf("BIO_new(BIO_s_file()) failed\n");
    exit(1);
  }
  BIO_set_fp(bio_err, stderr, BIO_NOCLOSE | BIO_FP_TEXT);

  if ((bundle_bio = BIO_new(BIO_s_file())) == NULL) {
    printf("BIO_new(BIO_s_file()) failed\n");
    return 0;
  }

  if (BIO_read_filename(bundle_bio, bundle_file) <= 0) {
    printf("error opening the file, %s\n", bundle_file);
    goto end;
  }

  if (d2i_PKCS7_bio(bundle_bio, &p7) == 0) {
    BIO_printf(bio_err, "unable to read pkcs7 object\n");
    ERR_print_errors(bio_err);
    goto end;
  }

  assert(OBJ_obj2nid(p7->type) == NID_pkcs7_signed);
  assert(p7->d.sign != NULL);
  assert(OBJ_obj2nid(p7->d.sign->contents->type) == NID_pkcs7_data);
  assert(ASN1_INTEGER_get(p7->d.sign->version) == 1);
  assert(p7->d.sign->crl != NULL);

  crl_stack = p7->d.sign->crl;
  count = sk_X509_CRL_num(crl_stack);
  //printf("found %d CRLs...\n", count);

  FILE* f = fopen(crl_file, "w");
  //for (int i=0; i<count; i++) {
  for (int i=count-1; i>=0; i--) {
    crl = sk_X509_CRL_value(crl_stack, i);
    assert(crl != NULL);
    PEM_write_X509_CRL(f, crl);
  }
  fclose(f);

  // now remove the crl_stack and save out the PK7 again
  p7->d.sign->crl = NULL;


  if ((vrl_bio = BIO_new(BIO_s_file())) == NULL) {
    printf("BIO_new(BIO_s_file()) failed\n");
    return 0;
  }

  if (BIO_write_filename(vrl_bio, vrl_file) <= 0) {
     perror(bundle_file);
     goto end;
  }

  if (i2d_PKCS7_bio(vrl_bio, p7) == 0) {
    BIO_printf(bio_err, "unable to write pkcs7 object\n");
    ERR_print_errors(bio_err);
    goto end;
  }

  ret = 1;

end:

  if (bundle_bio != NULL)
    BIO_free(bundle_bio);
  if (x509_info_stack != NULL)
    sk_X509_INFO_pop_free(x509_info_stack, X509_INFO_free);
  if (crl_stack != NULL)
    sk_X509_CRL_free(crl_stack);

  return ret;
}



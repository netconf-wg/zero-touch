#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <assert.h>
#include <openssl/bio.h>
#include <openssl/err.h>
#include <openssl/pem.h>
#include <openssl/x509.h>

// forawrd declarations
int packit(char* input, char* output);
int unpackit(char* input, char* output);

int main (int argc, char **argv) {

  int unpack_flag = 0;
  char input[256] = "";
  char output[256] = "";
  int c;

  while ((c = getopt (argc, argv, "i:o:r")) != -1) {
    switch (c) {
      case 'i':
        strlcpy(input, optarg, sizeof(input));
        break;
      case 'o':
        strlcpy(output, optarg, sizeof(output));
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

  if (!strlen(input) || !strlen(output)) {
    printf("\n");
    printf("Converts a multipart PEM file containing any number of CRLs\n");
    printf("into a PK7 (DER-encoded) file or, if run in reverse, converts\n");
    printf("a PK7 (DER-encoded) file containing any number of CRLs into a\n");
    printf("multipart PEM file.\n");
    printf("\n");
    printf("Usage: %s [-r] -i <input> -o <output>\n", argv[0]);
    printf("\n");
    printf("  -r: reverses the packing (i.e. pk7 --> pem)\n");
    printf("  -i: input filename (e.g., crls.pem)\n");
    printf("  -o: output filename (e.g., crls.pk7)\n");
    printf("\n");
    exit(1);
  }


  if (unpack_flag == 0) {
    //printf ("packing %s to %s...\n", input, output);
    if (!packit(input, output)) {
      printf("fatal error.\n");
      exit(1);
    }
  } else {
    //printf ("unpacking %s to %s...\n", input, output);
    if (!unpackit(input, output)) {
      printf("fatal error.\n");
      exit(1);
    }
  }

  exit (0);
}


int packit(char* input, char* output) {
  BIO* bio_err = NULL;
  BIO* in_bio = NULL;
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

  if ((in_bio = BIO_new(BIO_s_file())) == NULL) {
    printf("BIO_new(BIO_s_file()) failed\n");
    return 0;
  }

  if ((out_bio = BIO_new(BIO_s_file())) == NULL) {
    printf("BIO_new(BIO_s_file()) failed\n");
    return 0;
  }

  if (BIO_read_filename(in_bio, input) <= 0) {
    printf("error opening the file, %s\n", input);
    return 0;
  }

  x509_info_stack = PEM_X509_INFO_read_bio(in_bio, NULL, NULL, NULL);
  if (x509_info_stack == NULL) {
    printf("PEM_X509_INFO_read_bio(in_bio, NULL, NULL, NULL) failed\n");
    return 0;
  }

  crl_stack = sk_X509_CRL_new_null();
  if (crl_stack == NULL) {
    printf("sk_X509_CRL_new_null() failed\n");
    return 0;
  }

  count = sk_X509_INFO_num(x509_info_stack);
  printf("info: there is %d entries in the PEM file...\n", count);

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

  if ((p7 = PKCS7_new()) == NULL) {
    printf("PKCS7_new() failed\n");
    goto end;
  }
  p7->type = OBJ_nid2obj(NID_pkcs7_signed);
  p7->d.sign = PKCS7_SIGNED_new();
  if (p7->d.sign == NULL) {
    printf("PKCS7_SIGNED_new() failed\n");
    goto end;
  }
  p7->d.sign->contents->type = OBJ_nid2obj(NID_pkcs7_data);
  if (!ASN1_INTEGER_set(p7->d.sign->version, 1)) {
    printf("ASN1_INTEGER_set(p7s->version, 1) failed\n");
    goto end;
  }
  p7->d.sign->crl = crl_stack;

  if (BIO_write_filename(out_bio, output) <= 0) {
     perror(output);
     goto end;
  }

  if (i2d_PKCS7_bio(out_bio, p7) == 0) {
    BIO_printf(bio_err, "unable to write pkcs7 object\n");
    ERR_print_errors(bio_err);
    goto end;
  }

  ret = 1;

end:

  if (in_bio != NULL)
    BIO_free(in_bio);
  if (x509_info_stack != NULL)
    sk_X509_INFO_pop_free(x509_info_stack, X509_INFO_free);
  if (crl_stack != NULL)
    sk_X509_CRL_free(crl_stack);

  return ret;
}




int unpackit(char* input, char* output) {
  BIO* bio_err = NULL;
  BIO* in_bio = NULL;
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

  if ((in_bio = BIO_new(BIO_s_file())) == NULL) {
    printf("BIO_new(BIO_s_file()) failed\n");
    return 0;
  }

  if (BIO_read_filename(in_bio, input) <= 0) {
    printf("error opening the file, %s\n", input);
    goto end;
  }

  if (d2i_PKCS7_bio(in_bio, &p7) == 0) {
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

  FILE* f = fopen(output, "w");
  //for (int i=0; i<count; i++) {
  for (int i=count-1; i>=0; i--) {
    crl = sk_X509_CRL_value(crl_stack, i);
    assert(crl != NULL);
    PEM_write_X509_CRL(f, crl);
  }
  fclose(f);

  ret = 1;

end:

  if (in_bio != NULL)
    BIO_free(in_bio);
  if (x509_info_stack != NULL)
    sk_X509_INFO_pop_free(x509_info_stack, X509_INFO_free);
  if (crl_stack != NULL)
    sk_X509_CRL_free(crl_stack);

  return ret;
}


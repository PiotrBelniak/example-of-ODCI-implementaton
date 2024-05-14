CREATE OR REPLACE EDITIONABLE TYPE "C##METEO"."SECONDBESTTEMPIMPL" as object
(best_val NUMBER,
secbest NUMBER,
static function ODCIAggregateInitialize(sctx IN OUT SecondBestTempImpl) return number,
member function ODCIAggregateIterate(self IN OUT SecondBestTempImpl, value IN METEO_T) return number,
member function ODCIAggregateTerminate(self IN OUT SecondBestTempImpl, returnVal OUT number, flags IN NUMBER) return number,
member function ODCIAggregateMerge(self IN OUT SecondBestTempImpl, ctx2 IN SecondBestTempImpl) return number);
/
CREATE OR REPLACE EDITIONABLE TYPE BODY "C##METEO"."SECONDBESTTEMPIMPL" 
IS
    static function ODCIAggregateInitialize(sctx IN OUT SecondBestTempImpl) return number
    IS
    BEGIN
        sctx:=SecondBestTempImpl(-100,-99);
        return ODCIConst.Success;
    END ODCIAggregateInitialize;
    member function ODCIAggregateIterate(self IN OUT SecondBestTempImpl, value IN METEO_T) return number
    IS
        curval NUMBER;
    BEGIN
        FOR indx IN value.Zonereadings.FIRST..value.Zonereadings.LAST LOOP
            IF value.Zonereadings(indx).temperature>curval OR curval IS NULL THEN
                curval:=value.Zonereadings(indx).temperature;
            END IF;
        END LOOP;
        IF curval>self.best_val THEN
            self.secbest:=self.best_val;
            self.best_val:=curval;
        ELSIF curval< self.best_val AND curval>self.secbest THEN
            self.secbest:=curval;
        END IF;
        return ODCICOnst.Success;
    END ODCIAggregateIterate;
    member function ODCIAggregateTerminate(self IN OUT SecondBestTempImpl, returnVal OUT number, flags IN NUMBER) return number
    IS
    BEGIN
        returnVal:=self.secbest;
        return ODCIConst.Success;
    END ODCIAggregateTerminate;

    member function ODCIAggregateMerge(self IN OUT SecondBestTempImpl, ctx2 IN SecondBestTempImpl) return number
    IS
    BEGIN
        IF ctx2.secbest>self.best_val THEN
            self.secbest:=ctx2.secbest;
            self.best_val:=ctx2.best_val;
        ELSIF ctx2.best_val>self.best_val THEN
            self.secbest:=self.best_val;
            self.best_val:=ctx2.best_val;
        ELSIF ctx2.best_val>self.secbest THEN
            self.secbest:=ctx2.best_val;
        END IF;
        return ODCIConst.Success;
    END ODCIAggregateMerge;
END;

/
